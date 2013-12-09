"use strict";
var cocoConfig, compilerLib, init, libName, prefix, setCompilerLib, _;

_ = require('lodash');

compilerLib = null;

libName = "coco";

cocoConfig = {};

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

init = function(conf) {
  return cocoConfig = conf.coco;
};

prefix = function(file, cb) {
  var err, error, output;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  try {
    output = compilerLib.compile(file.inputFileText, _.extend({}, cocoConfig));
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "coco",
  type: "javascript",
  defaultExtensions: ["co", "coco"],
  init: init,
  compile: prefix,
  setCompilerLib: setCompilerLib
};
