"use strict";

var compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var prefix = function ( config ) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(function () { var templates = {};\n";
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
  var error, output;

  if ( !compilerLib ) {
    compilerLib = require( "underscore" );
  }

  // we don't want underscore to actually work, just to wrap stuff
  compilerLib.templateSettings = {
    evaluate    : /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
    interpolate : /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g
  };

  try {
    var compiledOutput = compilerLib.template( file.inputFileText );
    output = compiledOutput.source + "()";
  } catch ( err ) {
    error = err;
  }

  // set it back
  compilerLib.templateSettings = {
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g
  };

  cb( error, output );
};

module.exports = {
  name: "html",
  compilerType: "template",
  defaultExtensions: ["template"],
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};