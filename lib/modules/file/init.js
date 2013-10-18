"use strict";
var MimosaFileInitModule, fileUtils, fs, logger, path,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

path = require('path');

fs = require('fs');

logger = require('logmimosa');

fileUtils = require('../../util/file');

MimosaFileInitModule = (function() {
  function MimosaFileInitModule() {
    this.__determineDestinationFile = __bind(this.__determineDestinationFile, this);
    this._initMultiAsset = __bind(this._initMultiAsset, this);
    this._initSingleAsset = __bind(this._initSingleAsset, this);
  }

  MimosaFileInitModule.prototype.registration = function(config, register) {
    var cExts, e;
    e = config.extensions;
    cExts = config.copy.extensions;
    register(['add', 'update', 'remove', 'cleanFile', 'buildExtension'], 'init', this._initMultiAsset, __slice.call(e.template).concat(__slice.call(e.css)));
    return register(['add', 'update', 'remove', 'cleanFile', 'buildFile'], 'init', this._initSingleAsset, __slice.call(e.javascript).concat(__slice.call(cExts)));
  };

  MimosaFileInitModule.prototype._initSingleAsset = function(config, options, next) {
    var destinationFile, inputFile;
    inputFile = options.inputFile;
    this.__determineDestinationFile(config, options);
    destinationFile = options.destinationFile(inputFile);
    logger.debug("Destination for file [[ " + (inputFile != null ? inputFile : "template file") + " ]] is [[ " + destinationFile + " ]]");
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

  MimosaFileInitModule.prototype._initMultiAsset = function(config, options, next) {
    this.__determineDestinationFile(config, options);
    options.files = [];
    return next();
  };

  MimosaFileInitModule.prototype.__determineDestinationFile = function(config, options) {
    var destFunct, destinationFile, ext, exts,
      _this = this;
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
      var _this = this;
      return function(fileName) {
        return fileName.replace(watchDir, compiledDir);
      };
    }) : exts.javascript.indexOf(ext) > -1 ? (options.isJavascript = true, function(watchDir, compiledDir) {
      var _this = this;
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

  return MimosaFileInitModule;

})();

module.exports = new MimosaFileInitModule();
