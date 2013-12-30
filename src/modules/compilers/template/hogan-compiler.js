"use strict";

var compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var prefix = function ( config, libraryPath ) {
  if ( config.template.wrapType === 'amd' ) {
    return "define(['" + libraryPath + "'], function (Hogan){ var templates = {};\n";
  } else {
    if ( config.template.wrapType === "common" ) {
      return "var Hogan = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
    }
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

var compile = function (file, cb) {
  var error, output;

  if ( !compilerLib ) {
    compilerLib = require( "hogan.js" );
  }

  try {
    var compiledOutput = compilerLib.compile( file.inputFileText, {asString:true} );
    output = "templates['" + file.templateName + "'] = new Hogan.Template(" + compiledOutput + ");\n";
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  base: "hogan",
  compilerType: "template",
  defaultExtensions: ["hog", "hogan", "hjs"],
  clientLibrary: "hogan-template",
  compile: compile,
  suffix: suffix,
  prefix: prefix,
  setCompilerLib: setCompilerLib
};