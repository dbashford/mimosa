"use strict";
var compile, compilerLib, libName, prefix, setCompilerLib, suffix;

compilerLib = null;

libName = "ractive";

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (){ var templates = {};\n";
  } else {
    return "var templates = {};\n";
  }
};

suffix = function(config) {
  if (config.template.wrapType === 'amd') {
    return 'return templates; });';
  } else if (config.template.wrapType === "common") {
    return "module.exports = templates;";
  } else {
    return "";
  }
};

compile = function(file, cb) {
  var err, error, output;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  try {
    output = compilerLib.parse(file.inputFileText);
    output = JSON.stringify(output);
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "ractive",
  compilerType: "template",
  defaultExtensions: ["rtv", "rac"],
  clientLibrary: "ractive",
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
