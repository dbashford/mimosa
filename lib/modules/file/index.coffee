path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaFileModule

  lifecycleRegistration: (config, register) ->
    e = config.extensions
    cExts = config.copy.extensions
    register ['startupFile'], 'init',       @_initSingleAsset,           [e.javascript..., cExts...]
    register ['startupFile'], 'beforeRead', @_fileNeedsCompilingStartup, [e.javascript..., cExts...]
    register ['startupFile'], 'read',       @_read,                      [e.javascript..., cExts...]

    register ['startupExtension'],                         'init',       @_initSingleAsset,    [e.template...]

    register ['add','update','remove'],                    'init',       @_initSingleAsset,    [e.javascript..., cExts...]
    register ['add','update','remove','startupExtension'], 'init',       @_initMultiAsset,     [e.template..., e.css...]
    register ['add','update'],                             'beforeRead', @_fileNeedsCompiling, [e.javascript..., cExts...]
    register ['add','update'],                             'read',       @_read,               [e.javascript..., cExts...]
    register ['add','update','remove','startupExtension'], 'read',       @_read,               [e.css...]

    unless config.virgin
      register ['remove'],                           'delete', @_delete
      register ['add','update'],                     'write',  @_write,     [e.javascript..., cExts..., e.template...]
      register ['add','update','remove','startupExtension'], 'write',  @_write, [e.css...]
      register ['startupFile'],                      'write',  @_write,     [e.javascript..., cExts...]
      register ['startupExtension'],                 'write',  @_write,     [e.template...]

  _write: (config, options, next) =>
    return next(false) unless options.files?.length > 0

    i = 0
    options.files.forEach (file) =>
      return next() unless file.outputFileText? and file.outputFileName?
      logger.debug "Writing file [[ #{file.outputFileText} ]]"
      fileUtils.writeFile file.outputFileName, file.outputFileText, (err) =>
        logger.error "Failed to write new file: #{file.outputFileName}" if err?
        next() if ++i is options.files.length

  _delete: (config, options, next) =>
    fileName = options.destinationFile
    logger.debug "Removing file [[ #{fileName} ]]"
    fs.unlink fileName, (err) =>
      return logger.error "Failed to delete file: #{fileName}"
      # @success "Deleted compiled file [[ #{fileName} ]]"
      next()

  _read: (config, options, next) ->
    return next(false) unless options.files?.length > 0

    i = 0
    options.files.forEach (file) ->
      fs.readFile file.sourceFileName, (err, text) =>
        return logger.error "Failed to read file: #{file.sourceFileName}" if err?
        text = text.toString() if options.isJS or options.isCSS
        file.sourceFileText = text
        next() if ++i is options.files.length

  _fileNeedsCompiling: (config, options, next) ->
    return next(false) unless options.files?.length > 0

    i = 0
    numFiles = options.files.length
    newFiles = []
    options.files.forEach (file) ->
      fileUtils.isFirstFileNewer file.sourceFileName, file.outputFileName, (isNewer) ->
        newFiles.push file if isNewer
        if ++i is numFiles
          if newFiles.length > 0
            options.files = newFiles
            next()
          else
            next(false)

  # for anything javascript related, force compile regardless
  _fileNeedsCompilingStartup: (config, options, next) =>
    # force compiling on startup to build require dependency tree
    # but not for vendor javascript
    if config.requireRegister and options.isJSNotVendor(options.destinationFile)
      logger.debug "File [[ #{options.inputFile} ]] NEEDS compiling/copying"
      next()
    else
      @_fileNeedsCompiling(config, options, next)

  _initSingleAsset: (config, options, next) =>
    inputFile = options.inputFile

    options.destinationFile = @__determineDestinationFile config, options

    if options.destinationFile?
      logger.debug "Destination for file [[ #{inputFile ? "template file"} ]] is [[ #{destinationFile} ]]"

      destinationFile = options.destinationFile(inputFile)

      options.files = [{
        sourceFileName:inputFile
        outputFileName:destinationFile
        isVendor:fileUtils.isVendor(destinationFile)
        isJSNotVendor:fileUtils.isJSNotVendor(destinationFile)
        sourceFileText:null
        outputFileText:null
      }]

      next()
    else
      # no error, just unrecognized extension, warn and do not continue
      logger.warn "No compiler has been registered: #{options.extension}, #{inputFile}"
      next(false)

  _initMultiAsset: (config, options, next) =>
    options.destinationFile = @__determineDestinationFile config, options
    next()

  __determineDestinationFile: (config, options) =>
    exts = config.extensions
    ext = options.extension

    if exts.template.indexOf(ext) > -1
      options.isTemplate = true
      destFunct = (compiledJSDir) ->
        ->
          outputFileName = config.template.outputFileName
          if outputFileName[ext]
            path.join(compiledJSDir, outputFileName[ext] + ".js")
          else
            path.join(compiledJSDir, outputFileName + ".js")
      destFunct(config.watch.compiledJavascriptDir)
    else
      destFunct = if exts.copy.indexOf(ext) > -1
        options.isCopy = true
        destFunct = (watchDir, compiledDir) ->
          (fileName) =>
            fileName.replace(watchDir, compiledDir)
      else if exts.javascript.indexOf(ext) > -1
        options.isJS = true
        destFunct = (watchDir, compiledDir) ->
          (fileName) =>
            baseCompDir = fileName.replace(watchDir, compiledDir)
            baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js"
      else if exts.css.indexOf(ext) > -1
        options.isCSS = true
        destFunct = (watchDir, compiledDir) ->
          (fileName) ->
            baseCompDir = fileName.replace(watchDir, compiledDir)
            baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css"

      destFunct(config.watch.sourceDir, config.watch.compiledDir) if destFunct

module.exports = new MimosaFileModule()