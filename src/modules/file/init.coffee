"use strict"

path = require 'path'
fs =   require 'fs'

logger = require 'logmimosa'

fileUtils = require '../../util/file'

_determineDestinationFile = (config, options) ->
  exts = config.extensions
  ext = options.extension

  options.destinationFile = if exts.template.indexOf(ext) > -1
    options.isTemplate = true
    (compilerName, folders) =>
      for outputConfig in config.template.output
        if outputConfig.folders is folders
          outputFileName = outputConfig.outputFileName
          if outputFileName[compilerName]
            return path.join(config.watch.compiledDir, outputFileName[compilerName] + ".js")
          else
            return path.join(config.watch.compiledDir, outputFileName + ".js")
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

_initSingleAsset = (config, options, next) ->
  inputFile = options.inputFile

  _determineDestinationFile config, options

  destinationFile = options.destinationFile(inputFile)

  options.files = [{
    inputFileName:inputFile
    outputFileName:destinationFile
    inputFileText:null
    outputFileText:null
  }]

  next()

_initMultiAsset = (config, options, next) ->
  _determineDestinationFile config, options
  options.files = []
  next()

exports.registration = (config, register) ->
  e = config.extensions
  register ['add','update','remove','cleanFile','buildExtension'], 'init', _initMultiAsset,  [e.template..., e.css...]
  register ['add','update','remove','cleanFile','buildFile'],      'init', _initSingleAsset, [e.javascript..., e.copy...]