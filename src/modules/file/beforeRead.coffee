"use strict"

path = require 'path'

allExtensions = null

_notValidExtension = (file) ->
  ext = path.extname(file.inputFileName).replace(/\./,'')
  allExtensions.indexOf(ext) is -1

_fileNeedsCompiling = (config, options, next) ->
  hasFiles = options.files?.length > 0
  return next() unless hasFiles

  i = 0
  newFiles = []
  done = ->
    if ++i is options.files.length
      options.files = newFiles
      next()

  options.files.forEach (file) ->
    # if using require verification, forcing compile to assemble require information
    # or if extension is for file that was placed here, not that originated the workflow
    # like with .css files and CSS proprocessors
    if (options.isJavascript and config.__forceJavaScriptRecompile) or _notValidExtension(file)
      newFiles.push file
      done()
    else
      fileUtils = require '../../util/file'
      fileUtils.isFirstFileNewer file.inputFileName, file.outputFileName, (isNewer) ->
        if isNewer
          newFiles.push file
        else
          if config.log.isDebug()
            config.log.debug "Not processing [[ #{file.inputFileName} ]] as it is not newer than destination file."
        done()

_fileNeedsCompilingStartup = (config, options, next) ->
  # force compiling on startup to build require dependency tree
  # but not for vendor javascript
  if config.__forceJavaScriptRecompile and options.isJSNotVendor
    if config.log.isDebug()
      config.log.debug "File [[ #{options.inputFile} ]] NEEDS compiling/copying"
    next()
  else
    _fileNeedsCompiling(config, options, next)

exports.registration = (config, register) ->
  allExtensions = [config.extensions.javascript..., config.extensions.copy...]
  register ['buildFile'],    'beforeRead', _fileNeedsCompilingStartup, allExtensions
  register ['add','update'], 'beforeRead', _fileNeedsCompiling,        allExtensions