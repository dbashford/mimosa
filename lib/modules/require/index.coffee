path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'

requireRegister = require './register'
optimizer = require './optimize'

class MimosaRequireModule

  lifecycleRegistration: (config, register) ->

    return unless config.require.verify.enabled or config.optimize

    register ['add','update','startup'], 'afterCompile', [config.extensions.javascript...], @_requireRegister
    register ['remove'],                 'afterDelete',  [config.extensions.javascript...], @_requireDelete
    register ['postStartup'],            'complete',     ['*'],                             @_startupDone

    if config.optimize
      register ['remove'],       'afterDelete', [config.extensions.javascript...], @_requireOptimize
      register ['add','update'], 'afterWrite',  [config.extensions.javascript...], @_requireOptimize

    requireRegister.setConfig(config)

  _requireRegister: (config, options, next) ->
    return next() if options.isVendor
    requireRegister.process(options.destinationFile, options.output)
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
