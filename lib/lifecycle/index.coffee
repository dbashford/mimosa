path =   require 'path'

wrench = require 'wrench'
_ =      require 'lodash'

logger = require '../util/logger'

module.exports = class LifeCycleManager

  startup:true
  initialFilesHandled:0
  registration: {}

  types:
    startup:     ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    postStartup: ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    startupDone: ["init"]

    add:         ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    update:      ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    remove:      ["init", "beforeRead", "read", "afterRead", "beforeDelete",  "delete",  "afterDelete",  "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]

  constructor: (@config, modules) ->
    for type, steps of @types
      @registration[type] = {}
      for step in steps
        @registration[type][step] = {}

    module.lifecycleRegistration(@config, @register) for module in modules

    console.log @registration

    e = @config.extensions
    @allExtensions = [e.javascript..., e.css..., e.template..., config.copy.extensions...]
    files = wrench.readdirSyncRecursive(@config.watch.sourceDir).filter (f) =>
      ext = path.extname(f).substring(1)
      ext.length >= 1 and @allExtensions.indexOf(ext) >= 0

    @initialFileCount = files.length

    # compile, startup register for compilers css/template, just skip

    # register compilers
    # register logger
    # establish error object

  register: (types, step, extensions, callback) =>
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

      for extension in extensions
        console.log "Registering extension [[ #{extension} ]], for step [[ #{step} ]] of type [[ #{type} ]]"
        @registration[type][step][extension] ?= []
        @registration[type][step][extension].push callback

  update: (fileName) => @_executeLifecycleStep(@_buildAssetOptions(fileName), 'update')
  remove: (fileName) => @_executeLifecycleStep(@_buildAssetOptions(fileName), 'remove')
  add: (fileName) =>
    if @startup
      @_executeLifecycleStep(@_buildAssetOptions(fileName), 'startup')
    else
      @_executeLifecycleStep(@_buildAssetOptions(fileName), 'add')

  _buildAssetOptions: (fileName) ->
    ext = path.extname(fileName)
    ext = if ext.length > 1 then ext.substring(1) else ''
    {inputFile:fileName, extension:ext}

  _executeLifecycleStep: (options, type, done = @_finishedWithFile) ->
    options.lifeCycleType = type

    i = 0
    next = =>
      if i < @types[type].length
        @_lifecycleMethod type, @types[type][i++], options, cb
      else
        # finished naturally
        done(options)

    cb = (nextVal) =>
      if _.isBoolean(nextVal) and nextVal is false
        done(options)
      else if _.isString(nextVal)
        # TODO, increment i
        next()
        # fast forward
      else
        next()

    next()

  _lifecycleMethod: (type, step, options, done) ->
    logger.debug "Calling lifecycle: [[ #{type} ]], [[ #{step} ]], with options [[ #{JSON.stringify(options)} ]]"

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
      if _.isObject(nextVal)
        # is error, log the error and move on
        # TODO log error
        done(false)
      else if _.isBoolean(nextVal) and nextVal is false
        done(false)
        # no error, natural stop to workflow
      else if _.isString(nextVal)
        done(nextVal)
        # fast forward
      else
        # go to the next one
        next()

    next()

  _finishedWithFile: (options) =>
    if options.inputFile
      logger.debug "Finished with file: [[ #{options.inputFile} ]]"

    console.log "Finsihed with file: [[ #{options.inputFile} ]]"
    if @startup
      @initialFilesHandled++
      console.log @initialFileCount, @initialFilesHandled
      if @initialFileCount is @initialFilesHandled
        @startup = false
        console.log "WOOP WOOP WOOP WOOP, WE'RE DONE FOLKS!"
        for extension in @allExtensions
          done = 0
          @_executeLifecycleStep {extension:extension}, 'postStartup', =>
            if ++done is @allExtensions.length
              console.log "DONE WITH ALL EXTENSIONS"
