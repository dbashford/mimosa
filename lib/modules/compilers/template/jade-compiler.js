"use strict";
var _compile, _compilerLib, _prefix, _suffix;

_compilerLib = null;

_prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (jade){ var templates = {};\n";
  } else if (config.template.wrapType === "common") {
    return "var jade = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
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
  var err, error, output;
  try {
    output = _compilerLib.compile(file.inputFileText, {
      compileDebug: false,
      client: true,
      filename: file.inputFileName
    });
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "jade",
  type: "template",
  defaultExtensions: ["jade"],
  clientLibrary: "jade-runtime",
  libName: "jade",
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix,
  compilerLib: _compilerLib
};
