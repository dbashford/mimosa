module.exports = class JSCompiler

  lifecycleRegistration: (config, register) ->
    register ['add','update','startupFile'], 'compile', @_compile, [@extensions...]

  _compile: (config, options, next) =>
    i = 0
    newFiles = []
    options.files.forEach (file) =>
      @compile file, (err, output) =>
        if err
          console.log err
          # TODO handle logging
        else
          file.outputFileText = output
          newFiles.push file

        if ++i is options.files.length
          if newFiles.length is 0
            next(false)
          else
            options.files = newFiles
            next()