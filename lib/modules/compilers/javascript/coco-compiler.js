"use strict";
var _, _compile, _compilerLib, _config, _init;

_ = require('lodash');

_compilerLib = null;

_config = {};

_init = function(conf) {
  return _config = conf.coco;
};

_compile = function(file, cb) {
  var err, error, output;
  try {
    output = _compilerLib.compile(file.inputFileText, _.extend({}, _config));
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
  libName: 'coco',
  init: _init,
  compile: _compile,
  compilerLib: _compilerLib
};
