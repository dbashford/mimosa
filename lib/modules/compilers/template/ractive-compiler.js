"use strict";

var path = require( 'path' )
  , compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var prefix = function (config, libraryPath) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(['" + libraryPath + "'], function (){ var templates = {};\n";
  }

  return "var templates = {};\n";
};

var suffix = function ( config ) {
  if ( config.template.wrapType === 'amd' ) {
    return "return templates; });";
  } else {
    if ( config.template.wrapType === "common" ) {
      return "module.exports = templates;";
    }
  }

  return "";
};

var compile = function ( file, cb ) {
  var error, output;

  if ( !compilerLib ) {
    compilerLib = require( "ractive" );
  }

  try {
    output = compilerLib.parse( file.inputFileText );
    output = JSON.stringify( output );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  name: "ractive",
  compilerType: "template",
  defaultExtensions:  ["rtv","rac"],
  clientLibrary: path.join( __dirname, "client", "ractive.js" ),
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};