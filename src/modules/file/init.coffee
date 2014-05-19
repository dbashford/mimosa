"use strict"

_initSingleAsset = (config, options, next) ->
  fileUtils = require '../../util/file'
  fileUtils.setFileFlags( config, options )

  options.files = [{
    inputFileName:options.inputFile
    outputFileName:null
    inputFileText:null
    outputFileText:null
  }]

  next()

_initMultiAsset = (config, options, next) ->
  fileUtils = require '../../util/file'
  fileUtils.setFileFlags( config, options )
  options.files = []
  next()

exports.registration = (config, register) ->
  e = config.extensions
  register ['add','update','remove','cleanFile','buildExtension'], 'init', _initMultiAsset,  [e.template..., e.css...]
  register ['add','update','remove','cleanFile','buildFile'],      'init', _initSingleAsset, [e.javascript..., e.copy..., e.misc...]