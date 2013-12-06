"use strict";
var _compile, _compilerLib, _config, _init;

_compilerLib = null;

_config = {};

_init = function(conf) {
  return _config = conf.livescript;
};

_compile = function(file, cb) {
  var err, error, output;
  try {
    output = _compilerLib.compile(file.inputFileText, _config);
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
  libName: 'LiveScript',
  init: _init,
  compile: _compile,
  compilerLib: _compilerLib
};
