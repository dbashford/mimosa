"use strict"

path = require 'path'
fs =   require 'fs'

logger = require 'logmimosa'

fileUtils = require '../../util/file'

class MimosaFileInitModule

  registration: (config, register) ->
    e = config.extensions
    cExts = config.copy.extensions
    register ['add','update','remove','cleanFile','buildFile'],      'init', @_initSingleAsset, [e.javascript..., cExts...]
    register ['add','update','remove','cleanFile','buildExtension'], 'init', @_initMultiAsset,  [e.template..., e.css...]

  _initSingleAsset: (config, options, next) =>
    inputFile = options.inputFile

    @__determineDestinationFile config, options

    destinationFile = options.destinationFile(inputFile)

    logger.debug "Destination for file [[ #{inputFile ? "template file"} ]] is [[ #{destinationFile} ]]"

    options.files = [{
      inputFileName:inputFile
      outputFileName:destinationFile
      inputFileText:null
      outputFileText:null
    }]

    next()

  _initMultiAsset: (config, options, next) =>
    @__determineDestinationFile config, options
    next()

  __determineDestinationFile: (config, options) =>
    exts = config.extensions
    ext = options.extension

    options.destinationFile = if exts.template.indexOf(ext) > -1
      options.isTemplate = true
      compiledJSDir = config.watch.compiledJavascriptDir
      (compilerName, folders) =>
        for outputConfig in config.template.output
          if outputConfig.folders is folders
            outputFileName = outputConfig.outputFileName
            if outputFileName[compilerName]
              return path.join(compiledJSDir, outputFileName[compilerName] + ".js")
            else
              return path.join(compiledJSDir, outputFileName + ".js")
    else
      destFunct = if exts.copy.indexOf(ext) > -1
        options.isCopy = true
        (watchDir, compiledDir) ->
          (fileName) =>
            fileName.replace(watchDir, compiledDir)
      else if exts.javascript.indexOf(ext) > -1
        options.isJavascript = true
        (watchDir, compiledDir) ->
          (fileName) =>
            baseCompDir = fileName.replace(watchDir, compiledDir)
            baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js"
      else if exts.css.indexOf(ext) > -1
        options.isCSS = true
        (watchDir, compiledDir) ->
          (fileName) ->
            baseCompDir = fileName.replace(watchDir, compiledDir)
            baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css"

      destFunct(config.watch.sourceDir, config.watch.compiledDir) if destFunct

    if options.isTemplate
      options.isJavascript = true
      options.isCSS = false
      options.isVendor = false
      options.isJSNotVendor = true
    else if options.inputFile
      destinationFile = options.destinationFile(options.inputFile)
      options.isJavascript = fileUtils.isJavascript(destinationFile) unless options.isJavascript?
      options.isCSS = fileUtils.isCSS(destinationFile) unless options.isCSS?

      if options.isJavascript
        options.isVendor = fileUtils.isVendorJS(config, options.inputFile)

      if options.isCSS
        options.isVendor = fileUtils.isVendorCSS(config, options.inputFile)

      options.isJSNotVendor = options.isJavascript and not options.isVendor

module.exports = new MimosaFileInitModule()
