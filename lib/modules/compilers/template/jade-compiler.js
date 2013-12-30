"use strict";

var path = require( 'path' )
  , compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var prefix = function ( config, libraryPath ) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(['" + libraryPath + "'], function (jade){ var templates = {};\n";
  } else {
    if ( config.template.wrapType === "common" ) {
      return "var jade = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
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
  var output, error;

  if (!compilerLib) {
    compilerLib = require( "jade" );
  }

  try {
    var opts = {
      compileDebug: false,
      client: true,
      filename: file.inputFileName
    };

    output = compilerLib.compile( file.inputFileText, opts);
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  base: "jade",
  compilerType: "template",
  defaultExtensions:  ["jade"],
  clientLibrary: path.join( __dirname, "client", "jade-runtime.js" ),
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};