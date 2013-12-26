"use strict";
var compile, compilerLib, libName, prefix, setCompilerLib, suffix;

compilerLib = null;

libName = "jade";

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (jade){ var templates = {};\n";
  } else if (config.template.wrapType === "common") {
    return "var jade = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
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

compile = function(file, cb) {
  var err, error, output;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  try {
    output = compilerLib.compile(file.inputFileText, {
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
  compilerType: "template",
  defaultExtensions: ["jade"],
  clientLibrary: "jade-runtime",
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
