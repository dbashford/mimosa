"use strict";
var compile, compilerLib, libName, prefix, setCompilerLib, suffix;

compilerLib = null;

libName = "underscore";

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

prefix = function(config) {
  if (config.template.wrapType === 'amd') {
    return "define(function () { var templates = {};\n";
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
  compilerLib.templateSettings = {
    evaluate: /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
    interpolate: /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g
  };
  try {
    compiledOutput = compilerLib.template(file.inputFileText);
    output = "" + compiledOutput.source + "()";
  } catch (_error) {
    err = _error;
    error = err;
  }
  compilerLib.templateSettings = {
    evaluate: /<%([\s\S]+?)%>/g,
    interpolate: /<%=([\s\S]+?)%>/g
  };
  return cb(error, output);
};

module.exports = {
  base: "html",
  type: "template",
  defaultExtensions: ["template"],
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
