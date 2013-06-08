"use strict"

logger = require 'logmimosa'

fileUtils = require '../../util/file'

class MimosaFileBeforeReadModule

  registration: (config, register) ->
    e = config.extensions
    cExts = config.copy.extensions
    register ['buildFile'],    'beforeRead', @_fileNeedsCompilingStartup, [e.javascript..., cExts...]
    register ['add','update'], 'beforeRead', @_fileNeedsCompiling,        [e.javascript..., cExts...]

  _fileNeedsCompiling: (config, options, next) ->
    hasFiles = options.files?.length > 0
    return next(false) unless hasFiles

    i = 0
    newFiles = []
    done = ->
      if ++i is options.files.length
        if newFiles.length > 0
          options.files = newFiles
          next()
        else
          logger.debug "No files need compiling, exiting workflow"
          next(false)

    options.files.forEach (file) =>
      # if using require verification, forcing compile to assemble require information
      if options.isJavascript and config.requireRegister
        newFiles.push file
        done()
      else
        fileUtils.isFirstFileNewer file.inputFileName, file.outputFileName, (isNewer) =>
          newFiles.push file if isNewer
          done()

  _fileNeedsCompilingStartup: (config, options, next) =>
    # force compiling on startup to build require dependency tree
    # but not for vendor javascript
    if config.requireRegister and options.isJSNotVendor
      logger.debug "File [[ #{options.inputFile} ]] NEEDS compiling/copying"
      next()
    else
      @_fileNeedsCompiling(config, options, next)

module.exports = new MimosaFileBeforeReadModule()
