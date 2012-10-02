path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'

requireRegister = require './register'
optimizer = require './optimize'

class MimosaRequireModule

  lifecycleRegistration: (config, register) ->

    return unless config.require.verify.enabled or config.optimize

    register ['add','update','startupFile'], 'afterCompile', @_requireRegister, [config.extensions.javascript...]
    register ['remove'],                     'afterDelete',  @_requireDelete,   [config.extensions.javascript...]
    register ['startupDone'],                'init',         @_startupDone

    if config.optimize
      register ['remove'],       'afterDelete', @_requireOptimize, [config.extensions.javascript...]
      register ['add','update'], 'afterWrite',  @_requireOptimize, [config.extensions.javascript...]
      register ['startupDone'],  'init',  @_requireOptimize

    requireRegister.setConfig(config)

  _requireRegister: (config, options, next) ->
    return next() if options.isVendor
    requireRegister.process(options.files[0].outputFileName, options.files[0].outputFileText)
    next()

  _requireDelete: (config, options, next) ->
    requireRegister.remove(options.files[0].inputFileName)
    next()

  _requireOptimize: (config, options, next) ->
    optimizer.optimize(config, options.files[0].outputFileName)
    next()

  _startupDone: (config, options, next) ->
    requireRegister.startupDone()
    next()

module.exports = new MimosaRequireModule()
