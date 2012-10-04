module.exports = class CopyCompiler

  constructor: (config) ->
    @extensions = config.copy.extensions
    console.log config.copy.extensions

  lifecycleRegistration: (config, register) ->
    console.log "COPY REGISTRATION: ", @extensions...
    register ['add','update','startupFile'], 'compile', @compile, [@extensions...]

  compile: (config, options, next) ->
    console.log "INSIDE COPY!!!!!"

    return next() unless options.files?.length > 0
    options.files.forEach (file) =>
      console.log file.inputFileName
      file.outputFileText = file.inputFileText

    next()