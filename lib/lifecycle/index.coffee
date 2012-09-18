path =      require 'path'

wrench = require 'wrench'

logger = require '../util/logger'

module.exports = class LifeCycleManager

  startup:true

  types:
    add:["beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete", "startupComplete"]
    update:["beforeRead", "read", "afterRead", "beforeCompile", "compile", "afterCompile", "beforeWrite", "write", "afterWrite", "complete"]
    remove:["beforeRead", "read", "afterRead", "beforeDelete", "delete", "afterDelete", "complete"]
    startup:null

  registration: {}

  constructor: (@config, modules) ->
    @types.startup = ['init', @types.add..., 'startupDone']

    for type, steps of @types
      @registration[type] = {}
      for step in steps
        @registration[type][step] = {}

    @lifecycleRegistration(module) for module in modules

    # register reader
    # register writer
    # register compilers
    # register lint
    # register logger
    # establish error object
    # register requireRegister
    # register requireOptimizer
    # register minifier
    # register
    # beforeRead(inputFileName, destinationFileName, done)
    # read(inputFileName, done)
    # afterRead(inputFileName, text, done)
    # beforeCompile(inputFileName, destinationFileName, text, done)
    # compile()

  lifecycleRegistration: (module) ->

    modulesReg = module.lifecycleRegistration(@config)
    for moduleReg in modulesReg
      for type in moduleReg.types

        if !@types[type]?
          logger.fatal "Unrecognized lifecycle type [[ #{type} ]], valid types are [[ #{Object.keys(@types).join(',')} ]]"
          process.exit 1

        if @types[type].indexOf(moduleReg.step) < 0
          logger.fatal "Unrecognized lifecycle step [[ #{moduleReg.step} ]] for type [[ #{type} ]], valid steps are [[ #{@types[type]} ]]"
          process.exit 1

        for extension in moduleReg.extensions
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
    options =
      inputFile:fileName
      extension:path.extname(fileName).substring(1)
      lifeCycleType:type

    i = 0
    next = =>
      if i < @types[type].length
        @_lifeCycleMethod type, @types[type][i++], options, cb
    cb = (error) ->
      if error
        # log the error and move on
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
        done()
    cb = (error) ->
      if error
        # log the error and move on
      else
        next()
    next()
