path =   require 'path'

wrench = require 'wrench'
_ =      require 'lodash'

logger = require '../util/logger'

compilers = require '../modules/compilers'

module.exports = class LifeCycleManager

  startup:true
  initialFilesHandled:0
  registration: {}

  types:
    startupFile:      ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    startupExtension: ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    startupDone:      ["init"]

    add:    ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    update: ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    remove: ["init", "beforeRead", "read", "afterRead", "beforeDelete",  "delete",  "afterDelete",  "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]

  constructor: (@config, modules, @startupDoneCallback) ->
    compilers.setupCompilers(@config)

    for type, steps of @types
      @registration[type] = {}
      for step in steps
        @registration[type][step] = {}

    module.lifecycleRegistration(@config, @register) for module in modules

    @cleanUpRegistration()

    #console.log @registration

    e = @config.extensions
    @allExtensions = [e.javascript..., e.css..., e.template..., config.copy.extensions...]
    files = wrench.readdirSyncRecursive(@config.watch.sourceDir).filter (f) =>
      ext = path.extname(f).substring(1)
      ext.length >= 1 and @allExtensions.indexOf(ext) >= 0

    @initialFileCount = files.length
    @initialFiles = files


  cleanUpRegistration: =>
    logger.debug "Cleaning up unused lifecycle steps"

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
      return logger.warn "Lifecycle types not passed in as array: [[ #{types} ]], ending registration for plugin."

    unless _.isArray(extensions)
      return logger.warn "Lifecycle extensions not passed in as array: [[ #{extensions} ]], ending registration for plugin."

    unless _.isString(step)
      return logger.warn "Lifecycle step not passed in as string: [[ #{step} ]], ending registration for plugin."

    unless _.isFunction(callback)
      return logger.warn "Lifecycle callback not passed in as function: [[ #{callback} ]], ending registration for plugin."

    for type in types

      unless @types[type]?
        return logger.warn "Unrecognized lifecycle type [[ #{type} ]], valid types are [[ #{Object.keys(@types).join(',')} ]], ending registration for plugin."

      if @types[type].indexOf(step) < 0
        return logger.warn "Unrecognized lifecycle step [[ #{step} ]] for type [[ #{type} ]], valid steps are [[ #{@types[type]} ]]"

      # no registering the same extension twice
      for extension in _.uniq(extensions)
        if @registration[type][step][extension]?
          if @registration[type][step][extension].indexOf(callback) >= 0
            logger.debug "Callback already registered for this extension, ignoring:", type, step, extension
            continue
        else
          @registration[type][step][extension] ?= []

        @registration[type][step][extension].push callback

  update: (fileName) => @_executeLifecycleStep(@_buildAssetOptions(fileName), 'update')
  remove: (fileName) => @_executeLifecycleStep(@_buildAssetOptions(fileName), 'remove')
  add: (fileName) =>
    if @startup
      @_executeLifecycleStep(@_buildAssetOptions(fileName), 'startupFile')
    else
      @_executeLifecycleStep(@_buildAssetOptions(fileName), 'add')

  _buildAssetOptions: (fileName) ->
    ext = path.extname(fileName)
    ext = if ext.length > 1 then ext.substring(1) else ''
    {inputFile:fileName, extension:ext}

  _executeLifecycleStep: (options, type, done = @_finishedWithFile) ->
    options.lifeCycleType = type

    # if processing a file, and the file's extension isn't in the list, boot it
    if options.inputFile? and @allExtensions.indexOf(options.extension) is -1
      return logger.warn "No compiler has been registered for extension: [[ #{options.extension} ]], file: [[ #{options.inputFile} ]]"

    i = 0
    next = =>
      if i < @types[type].length
        @_lifecycleMethod type, @types[type][i++], options, cb
      else
        # finished naturally
        done(options)

    cb = (nextVal) =>
      if _.isBoolean(nextVal) and not nextVal
        done(options)
      else
        next()

    next()

  _lifecycleMethod: (type, step, options, done) ->
    logger.debug "Calling lifecycle: [[ #{type} ]], [[ #{step} ]], [[ #{options.extension} ]], [[ #{options.inputFile} ]]"

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
        # natural finish to lifecycle step
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
      @_startupExtensions()

  _startupExtensions: =>
    @startup = false
    done = 0
    # go through startup for each extension
    @allExtensions.forEach (extension) =>
      @_executeLifecycleStep {extension:extension}, 'startupExtension', =>
        @_startupDone() if ++done is @allExtensions.length

  _startupDone: =>
    # wrap up, startupDone
    @_executeLifecycleStep {}, 'startupDone', =>
      if @startupDoneCallback? then @startupDoneCallback()
