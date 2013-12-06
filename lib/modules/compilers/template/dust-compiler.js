"use strict";
var _compile, _compilerLib, _prefix, _suffix;

_compilerLib = null;

_prefix = function(config, libraryPath) {
  if (config.template.wrapType === "amd") {
    return "define(['" + libraryPath + "'], function (dust){ ";
  } else if (config.template.wrapType === "common") {
    return "var dust = require('" + config.template.commonLibPath + "');\n";
  } else {
    return "";
  }
};

_suffix = function(config) {
  if (config.template.wrapType === "amd") {
    return 'return dust; });';
  } else if (config.template.wrapType === "common") {
    return "\nmodule.exports = dust;";
  } else {
    return "";
  }
};

_compile = function(file, cb) {
  var err, error, output;
  try {
    output = _compilerLib.compile(file.inputFileText, file.templateName);
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
  libName: 'dustjs-linkedin',
  clientLibrary: "dust",
  handlesNamespacing: true,
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix,
  compilerLib: _compilerLib
};
