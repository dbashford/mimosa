"use strict";
var compile, compilerLib, init, libName, liveConfig, setCompilerLib;

liveConfig = {};

compilerLib = null;

libName = 'LiveScript';

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

init = function(conf) {
  return liveConfig = conf.livescript;
};

compile = function(file, cb) {
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
  compilerType: "javascript",
  defaultExtensions: ["ls"],
  init: init,
  compile: compile,
  setCompilerLib: setCompilerLib
};
