path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'

requireRegister = require './register'
optimizer = require './optimize'

class MimosaRequireModule

  lifecycleRegistration: (config, register) ->

    return unless config.require.verify.enabled or config.optimize
    e = config.extensions
    register ['add','update','buildFile'],      'afterCompile', @_requireRegister, [e.javascript...]
    register ['add','update','buildExtension'], 'afterCompile', @_requireRegister, [e.template...]
    register ['remove'],                        'afterDelete',  @_requireDelete,   [e.javascript...]
    register ['buildDone'],                     'init',         @_buildDone

    if config.optimize
      register ['add','update','remove'], 'afterWrite',  @_requireOptimizeFile, [e.javascript..., e.template...]
      register ['buildDone'],             'init',        @_requireOptimize

    requireRegister.setConfig(config)

  _requireDelete: (config, options, next) ->
    return next() unless options.files?.length > 0
    requireRegister.remove(options.files[0].inputFileName)
    next()

  _requireRegister: (config, options, next) ->
    return next() unless options.files?.length > 0
    return next() if options.isVendor
    options.files.forEach (file) ->
      if file.outputFileName and file.outputFileText
        if config.virgin
          requireRegister.process(file.inputFileName, file.outputFileText)
        else
          requireRegister.process(file.outputFileName, file.outputFileText)

    next()

  _requireOptimizeFile: (config, options, next) ->
    return next() unless options.files?.length > 0
    options.files.forEach (file) ->
      if file.outputFileName and file.outputFileText
        optimizer.optimize(config, file.outputFileName)
    next()

  _requireOptimize: (config, options, next) ->
    optimizer.optimize(config)
    next()

  _buildDone: (config, options, next) ->
    requireRegister.buildDone()
    next()

module.exports = new MimosaRequireModule()
