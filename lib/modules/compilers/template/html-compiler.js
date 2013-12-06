"use strict";
var _compile, _compilerLib, _prefix, _suffix;

_compilerLib = null;

_prefix = function(config) {
  if (config.template.wrapType === 'amd') {
    return "define(function () { var templates = {};\n";
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
  _compilerLib.templateSettings = {
    evaluate: /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
    interpolate: /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g
  };
  try {
    compiledOutput = _compilerLib.template(file.inputFileText);
    output = "" + compiledOutput.source + "()";
  } catch (_error) {
    err = _error;
    error = err;
  }
  _compilerLib.templateSettings = {
    evaluate: /<%([\s\S]+?)%>/g,
    interpolate: /<%=([\s\S]+?)%>/g
  };
  return cb(error, output);
};

module.exports = {
  base: "html",
  type: "template",
  defaultExtensions: ["template"],
  libName: "underscore",
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix,
  compilerLib: _compilerLib
};
