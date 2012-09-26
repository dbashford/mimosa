path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaFileModule

  lifecycleRegistration: (config, register) ->
    e = config.extensions
    cExts = config.copy.extensions
    register ['add','update','remove'], 'init',       @_buildAssetMetaData
    register ['startupFile'],           'init',       @_buildAssetMetaData,        [e.javascript..., cExts...]
    register ['add','update'],          'beforeRead', @_fileNeedsCompiling
    register ['startupFile'],           'beforeRead', @_fileNeedsCompilingStartup, [e.javascript..., cExts...]
    register ['add','update'],          'read',       @_read,                      [e.javascript..., e.css..., cExts...]
    register ['startupFile'],           'read',       @_read,                      [e.javascript..., cExts...]

    unless config.virgin
      register ['remove'],           'delete', @_delete
      register ['add','update'],     'write',  @_write
      register ['startupFile'],      'write',  @_write,  [e.javascript..., cExts...]
      register ['startupExtension'], 'write',  @_write,  [e.template...]

  _write: (config, options, next) =>
    destinationFile = options.destinationFile
    content = options.output

    return next() unless content?

    logger.debug "Writing file [[ #{destinationFile} ]]"
    fileUtils.writeFile destinationFile, content, (err) =>
      if err
        next({})
        return @failed "Failed to write new file: #{destinationFile}"
      # @success "Compiled/copied [[ #{fileName} ]]"
      next()

  _delete: (config, options, next) =>
    fileName = options.destinationFile
    logger.debug "Removing file [[ #{fileName} ]]"
    fs.unlink fileName, (err) =>
      unless err?
        # @success "Deleted compiled file [[ #{fileName} ]]"
        next()

  _read: (config, options, next) ->
    fs.readFile options.inputFile, (err, text) =>
      next({}) if err
      text = text.toString() if options.isJS or options.isCSS
      options.fileContent = text
      next()

  _fileNeedsCompiling: (config, options, next) ->
    inputFile = options.inputFile
    destinationFile = options.destinationFile

    next(false) unless inputFile?

    fileUtils.isFirstFileNewer inputFile, destinationFile, (isNewer) ->
      if isNewer then next() else next(false)

  # for anything javascript related, force compile regardless
  _fileNeedsCompilingStartup: (config, options, next) =>
    # force compiling on startup to build require dependency tree
    # but not for vendor javascript
    if config.requireRegister and options.isJSNotVendor(options.destinationFile)
      logger.debug "File [[ #{options.inputFile} ]] NEEDS compiling/copying"
      next()
    else
      @_fileNeedsCompiling(config, options, next)

  _buildAssetMetaData: (config, options, next) ->
    logger.debug "Executing modules.file.beforeRead"

    # shortcut variables
    inputFile = options.inputFile
    watchDir = config.watch.sourceDir
    compiledDir = config.watch.compiledDir
    compiledJSDir = config.watch.compiledJavascriptDir
    exts = config.extensions
    ext = options.extension

    destinationFile = if exts.template.indexOf(ext) > -1
      options.isTemplate = true
      outputFileName = config.template.outputFileName
      if outputFileName[ext]
        path.join(compiledJSDir, outputFileName[ext] + ".js")
      else
        path.join(compiledJSDir, outputFileName + ".js")
    else
      baseCompDir = inputFile.replace(watchDir, compiledDir)
      if exts.copy.indexOf(ext) > -1
        options.isCopy = true
        baseCompDir
      else if exts.javascript.indexOf(ext) > -1
        options.isJS = true
        baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js"
      else if exts.css.indexOf(ext) > -1
        options.isCSS = true
        baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css"

    if destinationFile?
      logger.debug "Destination for file [[ #{inputFile ? "template file"} ]] is [[ #{destinationFile} ]]"

      # add various asset metadata to options
      options.destinationFile = destinationFile
      options.isVendor = fileUtils.isVendor(destinationFile)
      options.isJSNotVendor = fileUtils.isJSNotVendor(destinationFile)

      next()
    else
      # no error, just unrecognized extension, warn and do not continue
      logger.warn "No compiler has been registered: #{ext}, #{inputFile}"
      next(false)

module.exports = new MimosaFileModule()