path =   require 'path'

wrench = require 'wrench'
_ =      require 'lodash'
logger = require 'logmimosa'

compilers = require '../modules/compilers'
util      = require './util'

module.exports = class WorkflowManager

  startup:true
  initialFilesHandled:0
  registration: {}

  masterTypes:
    buildFile:      ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "complete"]
    buildExtension: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "complete"]
    buildDone:      ["init", "beforeOptimize", "optimize", "afterOptimize", "beforeServer", "server", "afterServer", "beforePackage", "package", "afterPackage", "beforeInstall", "install", "afterInstall", "complete"]

    add:    ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]
    update: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]
    remove: ["init", "beforeRead", "read", "afterRead", "beforeDelete",  "delete",  "afterDelete",  "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]

  constructor: (@config, modules, @buildDoneCallback) ->
    compilers.setupCompilers(@config)

    util.deepFreeze(@config)

    @types = _.clone(@masterTypes, true)
    for type, steps of @types
      @registration[type] = {}
      for step in steps
        @registration[type][step] = {}

    for module in modules
      module.registration(@config, @register) if module.registration?

    @cleanUpRegistration()

    e = @config.extensions
    @allExtensions = [e.javascript..., e.css..., e.template..., config.copy.extensions...]
    files = wrench.readdirSyncRecursive(@config.watch.sourceDir).filter (f) =>
      ext = path.extname(f).substring(1)
      f = path.join @config.watch.sourceDir, f
      isValidExtension = ext.length >= 1 and @allExtensions.indexOf(ext) >= 0
      isIgnored = false
      if @config.watch.excludeRegex? and f.match @config.watch.excludeRegex
        isIgnored = true
      if @config.watch.exclude? and @config.watch.exclude.indexOf(f) > -1
        isIgnored = true
      isValidExtension and not isIgnored

    @initialFileCount = files.length
    @initialFiles = files

  cleanUpRegistration: =>
    logger.debug "Cleaning up unused workflow steps"

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

  register: (types, step, callback, extensions = ['*']) =>
    unless _.isArray(types)
      return logger.warn "Workflow types not passed in as array: [[ #{types} ]], ending registration for plugin."

    unless _.isArray(extensions)
      return logger.warn "Workflow extensions not passed in as array: [[ #{extensions} ]], ending registration for plugin."

    unless _.isString(step)
      return logger.warn "Workflow step not passed in as string: [[ #{step} ]], ending registration for plugin."

    unless _.isFunction(callback)
      return logger.warn "Workflow callback not passed in as function: [[ #{callback} ]], ending registration for plugin."

    for type in types

      unless @types[type]?
        return logger.warn "Unrecognized workflow type [[ #{type} ]], valid types are [[ #{Object.keys(@types).join(',')} ]], ending registration for plugin."

      if @types[type].indexOf(step) < 0
        return logger.warn "Unrecognized workflow step [[ #{step} ]] for type [[ #{type} ]], valid steps are [[ #{@types[type]} ]]"

      # no registering the same extension twice
      for extension in _.uniq(extensions)
        if @registration[type][step][extension]?
          if @registration[type][step][extension].indexOf(callback) >= 0
            logger.debug "Callback already registered for this extension, ignoring:", type, step, extension
            continue
        else
          @registration[type][step][extension] ?= []

        @registration[type][step][extension].push callback

  update: (fileName) => @_executeWorkflowStep(@_buildAssetOptions(fileName), 'update')
  remove: (fileName) => @_executeWorkflowStep(@_buildAssetOptions(fileName), 'remove')
  add: (fileName) =>
    if @startup
      @_executeWorkflowStep(@_buildAssetOptions(fileName), 'buildFile')
    else
      @_executeWorkflowStep(@_buildAssetOptions(fileName), 'add')

  _buildAssetOptions: (fileName) ->
    ext = path.extname(fileName)
    ext = if ext.length > 1 then ext.substring(1) else ''
    {inputFile:fileName, extension:ext}

  _executeWorkflowStep: (options, type, done = @_finishedWithFile) ->
    options.lifeCycleType = type

    # if processing a file, and the file's extension isn't in the list, boot it
    if options.inputFile? and @allExtensions.indexOf(options.extension) is -1
      return logger.warn "No compiler has been registered for extension: [[ #{options.extension} ]], file: [[ #{options.inputFile} ]]"

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

  _workflowMethod: (type, step, options, done) ->
    logger.debug "Calling workflow: [[ #{type} ]], [[ #{step} ]], [[ #{options.extension} ]], [[ #{options.inputFile} ]]"

    tasks = []
    ext = options.extension
    step = @registration[type][step]
    if step[ext]? then tasks.push step[ext]...
    if step['*']? then tasks.push step['*']...

    i = 0
    next = =>
      if i < tasks.length
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

  hash:{}

  _finishedWithFile: (options) =>
    logger.debug "Finished with file: [[ #{options.inputFile} ]]"
    if @startup and ++@initialFilesHandled is @initialFileCount
      if @config.isClean
        if @buildDoneCallback? then @buildDoneCallback()
      else
        @_buildExtensions()

  _buildExtensions: =>
    @startup = false
    done = 0
    # go through startup for each extension
    @allExtensions.forEach (extension) =>
      @_executeWorkflowStep {extension:extension}, 'buildExtension', =>
        @_buildDone() if ++done is @allExtensions.length

  _buildDone: =>
    # wrap up, buildDone
    @_executeWorkflowStep {}, 'buildDone', =>
      if @buildDoneCallback? then @buildDoneCallback()