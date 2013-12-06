"use strict";
var _, _compile, _compilerLib, _init, _prefix, _suffix;

_ = require('lodash');

_compilerLib = null;

_init = function(config, compiler) {
  module.exports.libName = compiler.libName;
  return module.exports.clientLibrary = compiler.clientLibrary;
};

_prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (_) { var templates = {};\n";
  } else if (config.template.wrapType === "common") {
    return "var _ = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
  } else {
    return "var templates = {};\n";
  }
};

_suffix = function(config) {
  if (config.template.wrapType === 'amd') {
    return 'return templates; });';
  } else if (config.template.wrapType === "common") {
    return "\nmodule.exports = templates;";
  } else {
    return "";
  }
};

_compile = function(file, cb) {
  var compiledOutput, err, error, output;
  try {
    compiledOutput = _compilerLib.template(file.inputFileText);
    output = compiledOutput.source;
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "lodash",
  type: "template",
  defaultExtensions: ["tmpl", "lodash"],
  clientLibrary: "lodash",
  libName: "lodash",
  init: _init,
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix,
  compilerLib: _compilerLib
};
