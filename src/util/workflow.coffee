path =   require 'path'
fs =     require 'fs'

_ =      require 'lodash'
logger = require 'logmimosa'

compilers = require '../modules/compilers'
fileUtils = require './file'

module.exports = class WorkflowManager

  startup:true
  initialFilesHandled:0
  registration: {}
  doneFiles: []

  masterTypes:

    preClean:  ["init", "complete"]
    cleanFile:     ["init", "beforeRead", "read", "afterRead", "beforeDelete", "delete", "afterDelete", "complete"]
    postClean: ["init", "complete"]

    preBuild:       ["init", "complete"]
    buildFile:      ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "complete"]
    buildExtension: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "complete"]
    postBuild:      ["init", "betweenInitOptimize", "beforeOptimize", "optimize", "afterOptimize", "beforeServer", "server", "afterServer", "beforePackage", "package", "afterPackage", "beforeInstall", "install", "afterInstall", "complete"]

    add:    ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]
    update: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]
    remove: ["init", "beforeRead", "read", "afterRead", "beforeDelete",  "delete",  "afterDelete",  "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]

  constructor: (@config, modules, @buildDoneCallback) ->
    compilers.setupCompilers(@config)

    @types = _.clone(@masterTypes, true)
    for type, steps of @types
      @registration[type] = {}
      for step in steps
        @registration[type][step] = {}

    @allExtensions = []
    for module in modules
      if module.registration
        module.registration(@config, @register)
    @allExtensions = _.uniq(@allExtensions)

    @_cleanUpRegistration()
    #@_determineFileCount()

  initClean: (cb) =>
    @_init "preClean", cb

  initBuild: (cb) =>
    @_init "preBuild", cb

  postClean: (cb) =>
    @_executeWorkflowStep {}, 'postClean', cb

  # ready is called when all files are initially encountered on startup
  # can't do anything with this because mimosa cares not when the files
  # are encountered, but when mimosa's intial workflows are done processing
  # those files.  However, if ready is called and there were no files
  # processed, then there are no source code files.  Need to info
  # that to users and then continue on with further workflows
  ready: =>
    if @initialFileCount is 0
      logger.info "No files to be processed"
      @_initialFileProcessingDone()

  clean:  (fileName) =>
    @_executeWorkflowStep(@_buildAssetOptions(fileName), 'cleanFile')

  update: (fileName) =>
    @_executeWorkflowStep(@_buildAssetOptions(fileName), 'update')

  remove: (fileName) =>
    @_executeWorkflowStep(@_buildAssetOptions(fileName), 'remove')

  add: (fileName) =>
    if @startup
      @_executeWorkflowStep(@_buildAssetOptions(fileName), 'buildFile')
    else
      @_executeWorkflowStep(@_buildAssetOptions(fileName), 'add')

  register: (types, step, callback, extensions = ['*']) =>
    unless Array.isArray(types)
      return logger.warn "Workflow types not passed in as array: [[ #{types} ]], ending registration for module."

    unless Array.isArray(extensions)
      return logger.warn "Workflow extensions not passed in as array: [[ #{extensions} ]], ending registration for module."

    unless typeof step is "string"
      return logger.warn "Workflow step not passed in as string: [[ #{step} ]], ending registration for module."

    unless _.isFunction(callback)
      return logger.warn "Workflow callback not passed in as function: [[ #{callback} ]], ending registration for module."

    for type in types

      unless @types[type]?
        return logger.warn "Unrecognized workflow type [[ #{type} ]], valid types are [[ #{Object.keys(@types).join(',')} ]], ending registration for module."

      if @types[type].indexOf(step) < 0
        return logger.warn "Unrecognized workflow step [[ #{step} ]] for type [[ #{type} ]], valid steps are [[ #{@types[type]} ]]"

      # no registering the same extension twice
      for extension in _.uniq(extensions)

        extension = extension.toLowerCase()

        if @registration[type][step][extension]?
          if @registration[type][step][extension].indexOf(callback) >= 0
            logger.debug "Callback already registered for this extension, ignoring:", type, step, extension
            continue
        else
          @registration[type][step][extension] ?= []

        @allExtensions.push extension
        @registration[type][step][extension].push callback

  _init: (step, cb) =>
    @_executeWorkflowStep {}, step, =>
      # need to redetermine initial file count
      @_determineFileCount()
      cb()

  _determineFileCount: =>
    w = @config.watch
    files = fileUtils.readdirSyncRecursive(w.sourceDir, w.exclude, w.excludeRegex, true).filter (f) =>
      ext = path.extname(f).substring(1)
      ext.length >= 1 and @allExtensions.indexOf(ext) >= 0
    @initialFileCount = files.length
    # @initialFiles = files.map (f) => path.join @config.watch.sourceDir, f

  _cleanUpRegistration: =>
    #logger.debug "Cleaning up unused workflow steps"

    for type, typeReg of @registration
      for step, stepReg of typeReg
        if Object.keys(stepReg).length is 0
          i = 0
          for st in @types[type]
            if st is step
              @types[type].splice(i,1)
              break
            i++
          delete typeReg[step]

  _initialFileProcessingDone: =>
    if @config.isClean
      if @buildDoneCallback? then @buildDoneCallback()
    else
      @_buildExtensions()

  _buildAssetOptions: (fileName) ->
    ext = path.extname(fileName).toLowerCase()
    ext = if ext.length > 1
      ext.substring(1)
    else
      # is dot file?
      baseName = path.basename( fileName )
      if baseName.indexOf(".") is 0 and baseName.length > 1
        baseName.substring(1)
      else
        # no extension found
        ''

    {inputFile:fileName, extension:ext}

  _executeWorkflowStep: (options, type, done = @_finishedWithFile) ->
    options.lifeCycleType = type

    if options.inputFile?
      if options.extension.length is 0 and fs.existsSync(options.inputFile) and fs.statSync(options.inputFile).isDirectory()
        return logger.debug "Not handling directory [[ #{options.inputFile} ]]"

      # if processing a file, and the file's extension isn't in the list, boot it
      if @allExtensions.indexOf(options.extension) is -1
        if options.extension?.length is 0
          return logger.debug "No extension detected [[ #{options.inputFile} ]]."
        else
          return logger.warn "No module has registered for extension: [[ #{options.extension} ]], file: [[ #{options.inputFile} ]]"

      if @config.timer && @config.timer.enabled
        options.timer = {
          start: process.hrtime()
        }

    i = 0
    next = =>
      if i < @types[type].length
        @_workflowMethod type, @types[type][i++], options, cb
      else
        # finished naturally
        done(options)

    cb = (nextVal) =>
      if _.isBoolean(nextVal) and not nextVal
        done(options)
      else
        next()

    next()

  _workflowMethod: (type, _step, options, done) ->
    tasks = []
    ext = options.extension
    step = @registration[type][_step]
    if step[ext]? then tasks.push step[ext]...
    if step['*']? then tasks.push step['*']...

    i = 0
    next = =>
      if i < tasks.length
        #logger.debug "Calling workflow: [[ #{type} ]], [[ #{_step} ]], [[ #{options.extension} ]], [[ #{options.inputFile} ]]"
        #logger.debug options.files?.length
        tasks[i++](@config, options, cb)
      else
        # natural finish to workflow step
        done()

    cb = (nextVal) ->
      if _.isBoolean(nextVal) and not nextVal
        done(false)
        # no error, natural stop to workflow
      else
        # go to the next one
        next()

    next()

  _finishedWithFile: (options) =>
    if logger.isDebug()
      logger.debug "Finished with file [[ #{options.inputFile} ]]"

    # @_writeTime(options)

    #@doneFiles.push(options.inputFile)
    #console.log _.difference(@initialFiles, @doneFiles)
    #console.log "finished #{@initialFilesHandled + 1} of #{@initialFileCount}"
    if @startup and ++@initialFilesHandled is @initialFileCount
      @_initialFileProcessingDone()

  _buildExtensions: =>
    @startup = false
    done = 0
    # go through startup for each extension
    @allExtensions.forEach (extension) =>
      @_executeWorkflowStep {extension:extension}, 'buildExtension', =>
        @_buildDone() if ++done is @allExtensions.length

  _buildDone: =>
    # wrap up, buildDone
    @_executeWorkflowStep {}, 'postBuild', =>
      if @buildDoneCallback? then @buildDoneCallback()

  _writeTime: (options) ->
    if options.timer
      options.timer.end = process.hrtime()
      timeStart = options.timer.start[0] * 1000 + options.timer.start[1] / 1000
      timeEnd = options.timer.end[0] * 1000 + options.timer.end[1] / 1000
      time = Math.round(timeEnd - timeStart)
      if time > 1750
        time = (time / 1000).toFixed(2) + " milliseconds"
      else
        time = time + " microseconds"

      logger.info "Finished with file [[ #{options.inputFile} ]] in [[ #{time} ]]"