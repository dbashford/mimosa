module.exports = class CopyCompiler

  constructor: (config) ->
    @extensions = config.copy.extensions

  lifecycleRegistration: (config, register) ->
    register ['add','update','startupFile'], 'compile', @compile, [@extensions...]

  compile: (config, options, next) ->
    for file in options.files
      file.outputFileText = file.inputFileText
    next()