"use strict";
var _compile, _compilerLib, _prefix, _suffix;

_compilerLib = null;

_prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (Hogan){ var templates = {};\n";
  } else if (config.template.wrapType === "common") {
    return "var Hogan = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
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
    compiledOutput = _compilerLib.compile(file.inputFileText, {
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
  type: "template",
  defaultExtensions: ["hog", "hogan", "hjs"],
  clientLibrary: "hogan-template",
  libName: "hogan.js",
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix,
  compilerLib: _compilerLib
};
