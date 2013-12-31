"use strict";

var compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var compile = function ( mimosaConfig, file, cb ) {
  var output, error;

  if ( !compilerLib ) {
    compilerLib = require( 'LiveScript' );
  }

  try {
    output = compilerLib.compile( file.inputFileText, mimosaConfig.livescript );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  name: "livescript",
  compilerType: "javascript",
  defaultExtensions: ["ls"],
  compile: compile,
  setCompilerLib: setCompilerLib
};