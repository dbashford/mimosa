"use strict";
var cocoConfig, compile, compilerLib, init, libName, setCompilerLib, _;

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

compile = function(file, cb) {
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
  compilerType: "javascript",
  defaultExtensions: ["co", "coco"],
  init: init,
  compile: compile,
  setCompilerLib: setCompilerLib
};
