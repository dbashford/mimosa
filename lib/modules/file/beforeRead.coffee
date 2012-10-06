logger = require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaFileBeforeReadModule

  lifecycleRegistration: (config, register) ->
    e = config.extensions
    cExts = config.copy.extensions
    register ['startupFile'],  'beforeRead', @_fileNeedsCompilingStartup, [e.javascript..., cExts...]
    register ['add','update'], 'beforeRead', @_fileNeedsCompiling,        [e.javascript..., cExts...]

  _fileNeedsCompiling: (config, options, next) ->
    return next(false) unless options.files?.length > 0

    i = 0
    newFiles = []
    options.files.forEach (file) =>
      # if using require verification, forcing compile to assemble require information
      if file.isJavascript and (config.require.verify.enabled or config.optimize)
        newFiles.push file
        if ++i is options.files.length
          if newFiles.length > 0
            options.files = newFiles
            next()
          else
            logger.debug "No files need compiling, exiting lifecycle"
            next(false)
      else
        fileUtils.isFirstFileNewer file.inputFileName, file.outputFileName, (isNewer) =>
          newFiles.push file if isNewer
          if ++i is options.files.length
            if newFiles.length > 0
              options.files = newFiles
              next()
            else
              logger.debug "No files need compiling, exiting lifecycle"
              next(false)

  _fileNeedsCompilingStartup: (config, options, next) =>
    # force compiling on startup to build require dependency tree
    # but not for vendor javascript
    if config.requireRegister and options.isJSNotVendor
      logger.debug "File [[ #{options.inputFile} ]] NEEDS compiling/copying"
      next()
    else
      @_fileNeedsCompiling(config, options, next)

module.exports = new MimosaFileBeforeReadModule()
