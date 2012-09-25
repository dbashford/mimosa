module.exports = class CopyCompiler

  constructor: (config) ->
    @extensions = config.copy.extensions

  lifecycleRegistration: (config, register) ->
    register ['add','update','startup'], 'compile', [@extensions...], @compile

  compile: (config, options, next) ->
    options.output = options.fileContent
    next()