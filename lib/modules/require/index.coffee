path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'

requireRegister = require './register'
optimizer = require './optimize'

class MimosaRequireModule

  lifecycleRegistration: (config) ->
    lifecycle = []

    return lifecycle unless config.require.verify.enabled or config.optimize

    requireRegister.setConfig(config)

    lifecycle.push
      types:['add','update','startup']
      step:'afterCompile'
      callback: @_requireRegister
      extensions:[config.extensions.javascript...]

    lifecycle.push
      types:['remove']
      step:'afterDelete'
      callback: @_requireDelete
      extensions:[config.extensions.javascript...]

    lifecycle.push
      types:['postStartup']
      step:'complete'
      callback: @_startupDone
      extensions:['*']

    if config.optimize

      lifecycle.push
        types:['remove']
        step:'afterDelete'
        callback: @_requireOptimize
        extensions:[config.extensions.javascript...]

      lifecycle.push
        types:['add','update']
        step:'afterWrite'
        callback: @_requireOptimize
        extensions:[config.extensions.javascript...]

    lifecycle

  _requireRegister: (config, options, next) ->
    return next() if options.isVendor
    requireRegister.process(options.destinationFile, options.fileContent)
    next()

  _requireDelete: (config, options, next) ->
    requireRegister.remove(options.inputFile)
    next()

  _requireOptimize: (config, options, next) ->
    optimizer.optimize(config, fileName)
    next()

  _startupDone: (config, options, next) ->
    requireRegister.startupDone()
    next()



module.exports = new MimosaRequireModule()
