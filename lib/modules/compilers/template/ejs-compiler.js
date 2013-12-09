"use strict";
var boilerplate, compile, compilerLib, libName, prefix, setCompilerLib, suffix, __transform;

compilerLib = null;

libName = 'ejs';

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

boilerplate = "var templates = {};\nvar globalEscape = function(html){\n  return String(html)\n    .replace(/&(?!\w+;)/g, '&amp;')\n    .replace(/</g, '&lt;')\n    .replace(/>/g, '&gt;')\n    .replace(/\"/g, '&quot;');\n};";

prefix = function(config, libraryPath) {
  if (config.template.wrapType === 'amd') {
    return "define(['" + libraryPath + "'], function (globalFilters){\n  " + boilerplate;
  } else if (config.template.wrapType === "common") {
    return "var globalFilters = require('" + config.template.commonLibPath + "');\n" + boilerplate;
  } else {
    return boilerplate;
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

__transform = function(output) {
  return output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;');
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
    output = __transform(output + "");
  } catch (_error) {
    err = _error;
    error = err;
  }
  return cb(error, output);
};

module.exports = {
  base: "ejs",
  type: "template",
  defaultExtensions: ["ejs"],
  clientLibrary: "ejs-filters",
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
