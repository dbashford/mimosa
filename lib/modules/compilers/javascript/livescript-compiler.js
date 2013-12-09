"use strict";
var compilerLib, init, libName, liveConfig, prefix, setCompilerLib;

liveConfig = {};

compilerLib = null;

libName = 'LiveScript';

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

init = function(conf) {
  return liveConfig = conf.livescript;
};

prefix = function(file, cb) {
  var err, error, output;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  try {
    output = compilerLib.compile(file.inputFileText, liveConfig);
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "livescript",
  type: "javascript",
  defaultExtensions: ["ls"],
  init: init,
  compile: prefix,
  setCompilerLib: setCompilerLib
};
