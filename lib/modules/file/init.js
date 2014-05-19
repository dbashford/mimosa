"use strict";
var _initMultiAsset, _initSingleAsset,
  __slice = [].slice;

_initSingleAsset = function(config, options, next) {
  var fileUtils;
  fileUtils = require('../../util/file');
  fileUtils.setFileFlags(config, options);
  options.files = [
    {
      inputFileName: options.inputFile,
      outputFileName: null,
      inputFileText: null,
      outputFileText: null
    }
  ];
  return next();
};

_initMultiAsset = function(config, options, next) {
  var fileUtils;
  fileUtils = require('../../util/file');
  fileUtils.setFileFlags(config, options);
  options.files = [];
  return next();
};

exports.registration = function(config, register) {
  var e;
  e = config.extensions;
  register(['add', 'update', 'remove', 'cleanFile', 'buildExtension'], 'init', _initMultiAsset, __slice.call(e.template).concat(__slice.call(e.css)));
  return register(['add', 'update', 'remove', 'cleanFile', 'buildFile'], 'init', _initSingleAsset, __slice.call(e.javascript).concat(__slice.call(e.copy), __slice.call(e.misc)));
};
