"use strict";
var compile, compilerLib, libName, prefix, setCompilerLib, suffix;

compilerLib = null;

libName = "hogan.js";

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (Hogan){ var templates = {};\n";
  } else if (config.template.wrapType === "common") {
    return "var Hogan = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
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
  var compiledOutput, err, error, output;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  try {
    compiledOutput = compilerLib.compile(file.inputFileText, {
      asString: true
    });
    output = "templates['" + file.templateName + "'] = new Hogan.Template(" + compiledOutput + ");\n";
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "hogan",
  compilerType: "template",
  defaultExtensions: ["hog", "hogan", "hjs"],
  clientLibrary: "hogan-template",
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
