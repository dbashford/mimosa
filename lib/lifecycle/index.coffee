path =   require 'path'

wrench = require 'wrench'
_ =      require 'lodash'

logger = require '../util/logger'

module.exports = class LifeCycleManager

  startup:true
  initialFilesHandled:0

  types:
    startup:     ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    add:         ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    update:      ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    remove:      ["init", "beforeRead", "read", "afterRead", "beforeDelete", "delete", "afterDelete", "complete"]
    postStartup: ["init", "beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]

  registration: {}

  constructor: (@config, modules) ->
    for type, steps of @types
      @registration[type] = {}
      for step in steps
        @registration[type][step] = {}

    @lifecycleRegistration(module) for module in modules

    e = @config.extensions
    extensions = [e.javascript..., e.css..., e.template..., config.copy.extensions...]
    files = wrench.readdirSyncRecursive(@config.watch.sourceDir).filter (f) =>
      ext = path.extname(f).substring(1)
      ext.length >= 1 and extensions.indexOf(ext) >= 0

    @initialFileCount = files.length

    # compile, startup register for compilers css/template, just skip

    # register compilers
    # register logger
    # establish error object

  lifecycleRegistration: (module) ->
    modulesReg = module.lifecycleRegistration(@config)
    for moduleReg in modulesReg
      continue if Object.keys(moduleReg).length is 0 # valid module registered no tasks

      for type in moduleReg.types

        if !@types[type]?
          logger.fatal "Unrecognized lifecycle type [[ #{type} ]], valid types are [[ #{Object.keys(@types).join(',')} ]]"
          process.exit 1

        if @types[type].indexOf(moduleReg.step) < 0
          logger.fatal "Unrecognized lifecycle step [[ #{moduleReg.step} ]] for type [[ #{type} ]], valid steps are [[ #{@types[type]} ]]"
          process.exit 1

        for extension in moduleReg.extensions
          console.log "Registering extension [[ #{extension} ]], for step [[ #{moduleReg.step} ]] of type [[ #{type} ]]"
          console.log moduleReg.callback
          @registration[type][moduleReg.step][extension] ?= []
          @registration[type][moduleReg.step][extension].push moduleReg.callback

  update: (fileName) => @_execute(fileName, 'update')
  remove: (fileName) => @_execute(fileName, 'remove')
  add: (fileName) =>
    if @startup
      @_execute(fileName, 'startup')
    else
      @_execute(fileName, 'add')

  _execute: (fileName, type) ->
    ext = path.extname(fileName)
    ext = if ext.length > 1 then ext.substring(1) else ''

    options =
      inputFile:fileName
      extension:ext
      lifeCycleType:type

    i = 0
    next = =>
      if i < @types[type].length
        @_lifeCycleMethod type, @types[type][i++], options, cb
      else
        # finished naturally
        @_finishedWithFile(options)

    cb = (nextVal) =>
      if _.isBoolean(nextVal) and nextVal is false
        @_finishedWithFile(options)
      else if _.isString(nextVal)
        # TODO, increment i
        next()
        # fast forward
      else
        next()

    next()

  _lifeCycleMethod: (type, step, options, done) ->
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

  _finishedWithFile: (options) ->
    logger.debug "Finished with file: [[ #{options.inputFile} ]]"
    #console.log "Finsihed with file: [[ #{options.inputFile} ]]"
    @initialFilesHandled++
    console.log @initialFileCount, @initialFilesHandled
    if  @initialFileCount is @initialFilesHandled
      console.log "WOOP WOOP WOOP WOOP, WE'RE DONE FOLKS!"