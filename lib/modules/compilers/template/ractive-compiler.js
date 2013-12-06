"use strict";
var _compile, _compilerLib, _prefix, _suffix;

_compilerLib = null;

_prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (){ var templates = {};\n";
  } else {
    return "var templates = {};\n";
  }
};

_suffix = function(config) {
  if (config.template.wrapType === 'amd') {
    return 'return templates; });';
  } else if (config.template.wrapType === "common") {
    return "module.exports = templates;";
  } else {
    return "";
  }
};

_compile = function(file, cb) {
  var err, error, output;
  try {
    output = _compilerLib.parse(file.inputFileText);
    output = JSON.stringify(output);
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "ractive",
  type: "template",
  defaultExtensions: ["rtv", "rac"],
  clientLibrary: "ractive",
  libName: "ractive",
  compilerLib: _compilerLib,
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix
};
