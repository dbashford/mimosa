module.exports = class CopyCompiler

  constructor: (config, @extensions) ->

  lifecycleRegistration: (config, register) ->
    register ['add','update','startupFile'], 'compile', @compile, [@extensions...]

  compile: (config, options, next) ->
    return next() unless options.files?.length > 0
    options.files.forEach (file) =>
      file.outputFileText = file.inputFileText

    next()