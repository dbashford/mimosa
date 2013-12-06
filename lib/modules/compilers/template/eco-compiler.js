"use strict";
var _compile, _compilerLib, _prefix, _suffix;

_compilerLib = null;

_prefix = function(config) {
  if (config.template.wrapType === 'amd') {
    return "define(function (){ var templates = {};\n";
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
    output = _compilerLib.precompile(file.inputFileText);
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "eco",
  type: "template",
  defaultExtensions: ["eco"],
  libName: 'eco',
  handlesNamespacing: true,
  compile: _compile,
  suffix: _suffix,
  prefix: _prefix,
  compilerLib: _compilerLib
};
