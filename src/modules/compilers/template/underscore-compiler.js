"use strict";

var compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var prefix = function ( config, libraryPath ) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(['" + libraryPath + "'], function (_) { var templates = {};\n";
  } else {
    if ( config.template.wrapType === "common" ) {
      return "var _ = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
    }
  }

  return "var templates = {};\n";
};

var suffix = function ( config ) {
  if ( config.template.wrapType === 'amd' ) {
    return 'return templates; });';
  } else {
    if ( config.template.wrapType === "common" ) {
      return "\nmodule.exports = templates;";
    }
  }

  return "";
};

var compile = function ( file, cb ) {
  var error, output;

  if ( !compilerLib ) {
    compilerLib = require( "underscore" );
  }

  try {
    var compiledOutput = compilerLib.template( file.inputFileText );
    output = compiledOutput.source;
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  base: "underscore",
  compilerType: "template",
  defaultExtensions:  ["tpl", "underscore"],
  clientLibrary: "underscore",
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
