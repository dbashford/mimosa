"use strict";

var path = require( 'path' )
  , compilerLib = null
  , _transform = function (output) {
    return output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;');
  }
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  }
  , boilerplate = "var templates = {};\n" +
    "var globalEscape = function(html){\n" +
    "  return String(html)\n" +
    "    .replace(/&(?!\w+;)/g, '&amp;')\n" +
    "    .replace(/</g, '&lt;')\n" +
    "    .replace(/>/g, '&gt;')\n" +
    "    .replace(/\"/g, '&quot;')};\n";

var prefix =  function ( config, libraryPath ) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(['" + libraryPath + "'], function (globalFilters){\n"  + boilerplate;
  } else {
    if ( config.template.wrapType === "common" ) {
      return "var globalFilters = require('" + config.template.commonLibPath + "')\n" + boilerplate;
    }
  }
  return boilerplate;
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
  var error, output;

  if ( !compilerLib ) {
    compilerLib = require( 'ejs' );
  }

  try {
    var opts = {
      compileDebug: false,
      client: true,
      filename: file.inputFileName
    };
    output = compilerLib.compile( file.inputFileText, opts );
    output = _transform( output + "" );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  base: "ejs",
  compilerType: "template",
  defaultExtensions: ["ejs"],
  clientLibrary: path.join( __dirname, "client", "ejs-filters.js" ),
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};