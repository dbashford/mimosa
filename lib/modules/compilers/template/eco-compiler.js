"use strict";

var compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var prefix = function ( config ) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(function (){ var templates = {};\n";
  }

  return "var templates = {};\n";
};

var suffix = function ( config ) {
  if ( config.template.wrapType === 'amd' ) {
    return "return templates; });";
  } else {
    if ( config.template.wrapType === "common" ) {
      return "\nmodule.exports = templates;";
    }
  }

  return "";
};

var compile = function ( file, cb ) {
  var output, error;

  if ( !compilerLib ) {
    compilerLib = require( 'eco' );
  }

  try {
    output = compilerLib.precompile( file.inputFileText );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  name: "eco",
  compilerType: "template",
  defaultExtensions: ["eco"],
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};
