"use strict";
var compilerLib, libName, prefix, setCompilerLib, suffix, _;

_ = require('lodash');

compilerLib = null;

libName = "lodash";

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (_) { var templates = {};\n";
  } else if (config.template.wrapType === "common") {
    return "var _ = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
  } else {
    return "var templates = {};\n";
  }
};

suffix = function(config) {
  if (config.template.wrapType === 'amd') {
    return 'return templates; });';
  } else if (config.template.wrapType === "common") {
    return "\nmodule.exports = templates;";
  } else {
    return "";
  }
};

prefix = function(file, cb) {
  var compiledOutput, err, error, output;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  try {
    compiledOutput = compilerLib.template(file.inputFileText);
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
  compile: prefix,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
