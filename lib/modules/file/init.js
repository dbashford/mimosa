"use strict";
var fileUtils, logger, path, _determineDestinationFile, _initMultiAsset, _initSingleAsset,
  __slice = [].slice;

path = require('path');

logger = require('logmimosa');

fileUtils = require('../../util/file');

_determineDestinationFile = function(config, options) {
  var destFunct, destinationFile, ext, exts;
  exts = config.extensions;
  ext = options.extension;
  options.destinationFile = exts.template.indexOf(ext) > -1 ? (options.isTemplate = true, function(compilerName, folders) {
    var outputConfig, outputFileName, _i, _len, _ref;
    _ref = config.template.output;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      outputConfig = _ref[_i];
      if (outputConfig.folders === folders) {
        outputFileName = outputConfig.outputFileName;
        if (outputFileName[compilerName]) {
          return path.join(config.watch.compiledDir, outputFileName[compilerName] + ".js");
        } else {
          return path.join(config.watch.compiledDir, outputFileName + ".js");
        }
      }
    }
  }) : (destFunct = exts.copy.indexOf(ext) > -1 ? (options.isCopy = true, function(watchDir, compiledDir) {
    return function(fileName) {
      return fileName.replace(watchDir, compiledDir);
    };
  }) : exts.javascript.indexOf(ext) > -1 ? (options.isJavascript = true, function(watchDir, compiledDir) {
    return function(fileName) {
      var baseCompDir;
      baseCompDir = fileName.replace(watchDir, compiledDir);
      return baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js";
    };
  }) : exts.css.indexOf(ext) > -1 ? (options.isCSS = true, function(watchDir, compiledDir) {
    return function(fileName) {
      var baseCompDir;
      baseCompDir = fileName.replace(watchDir, compiledDir);
      return baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css";
    };
  }) : void 0, destFunct ? destFunct(config.watch.sourceDir, config.watch.compiledDir) : void 0);
  if (options.isTemplate) {
    options.isJavascript = true;
    options.isCSS = false;
    options.isVendor = false;
    return options.isJSNotVendor = true;
  } else if (options.inputFile) {
    destinationFile = options.destinationFile(options.inputFile);
    if (options.isJavascript == null) {
      options.isJavascript = fileUtils.isJavascript(destinationFile);
    }
    if (options.isCSS == null) {
      options.isCSS = fileUtils.isCSS(destinationFile);
    }
    if (options.isJavascript) {
      options.isVendor = fileUtils.isVendorJS(config, options.inputFile);
    }
    if (options.isCSS) {
      options.isVendor = fileUtils.isVendorCSS(config, options.inputFile);
    }
    return options.isJSNotVendor = options.isJavascript && !options.isVendor;
  }
};

_initSingleAsset = function(config, options, next) {
  var destinationFile, inputFile;
  inputFile = options.inputFile;
  _determineDestinationFile(config, options);
  destinationFile = options.destinationFile(inputFile);
  options.files = [
    {
      inputFileName: inputFile,
      outputFileName: destinationFile,
      inputFileText: null,
      outputFileText: null
    }
  ];
  return next();
};

_initMultiAsset = function(config, options, next) {
  _determineDestinationFile(config, options);
  options.files = [];
  return next();
};

exports.registration = function(config, register) {
  var e;
  e = config.extensions;
  register(['add', 'update', 'remove', 'cleanFile', 'buildExtension'], 'init', _initMultiAsset, __slice.call(e.template).concat(__slice.call(e.css)));
  return register(['add', 'update', 'remove', 'cleanFile', 'buildFile'], 'init', _initSingleAsset, __slice.call(e.javascript).concat(__slice.call(e.copy)));
};
