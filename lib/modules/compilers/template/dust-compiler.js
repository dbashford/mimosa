"use strict";
var compile, compilerLib, libName, prefix, setCompilerLib, suffix;

compilerLib = null;

libName = 'dustjs-linkedin';

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

prefix = function(config, libraryPath) {
  if (config.template.wrapType === "amd") {
    return "define(['" + libraryPath + "'], function (dust){ ";
  } else if (config.template.wrapType === "common") {
    return "var dust = require('" + config.template.commonLibPath + "');\n";
  } else {
    return "";
  }
};

suffix = function(config) {
  if (config.template.wrapType === "amd") {
    return 'return dust; });';
  } else if (config.template.wrapType === "common") {
    return "\nmodule.exports = dust;";
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
    output = compilerLib.compile(file.inputFileText, file.templateName);
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "dust",
  type: "template",
  defaultExtensions: ["dust"],
  clientLibrary: "dust",
  handlesNamespacing: true,
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
