"use strict";

var liveConfig = {}
  , compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  }
  , init = function ( conf ) {
    liveConfig = conf.livescript;
  };

var compile = function ( file, cb ) {
  var output, error;

  if ( !compilerLib ) {
    compilerLib = require( 'LiveScript' );
  }

  try {
    output = compilerLib.compile( file.inputFileText, liveConfig );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  base: "livescript",
  compilerType: "javascript",
  defaultExtensions: ["ls"],
  init: init,
  compile: compile,
  setCompilerLib: setCompilerLib
};