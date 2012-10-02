path = require 'path'
fs =   require 'fs'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaFileInitModule

  lifecycleRegistration: (config, register) ->
    e = config.extensions
    cExts = config.copy.extensions
    register ['startupFile'],                              'init', @_initSingleAsset, [e.javascript..., cExts...]
    register ['add','update','remove'],                    'init', @_initSingleAsset, [e.javascript..., cExts...]
    register ['add','update','remove','startupExtension'], 'init', @_initMultiAsset,  [e.template..., e.css...]

  _initSingleAsset: (config, options, next) =>
    inputFile = options.inputFile

    options.destinationFile = @__determineDestinationFile config, options

    if options.destinationFile?
      logger.debug "Destination for file [[ #{inputFile ? "template file"} ]] is [[ #{destinationFile} ]]"

      destinationFile = options.destinationFile(inputFile)

      options.files = [{
        inputFileName:inputFile
        outputFileName:destinationFile
        isVendor:fileUtils.isVendor(destinationFile)
        isJSNotVendor:fileUtils.isJSNotVendor(destinationFile)
        inputFileText:null
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

module.exports = new MimosaFileInitModule()
