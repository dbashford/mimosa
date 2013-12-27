"use strict";

var _ = require( 'lodash' )
  , compilerLib = null
  , cocoConfig = {}
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  }
  , init = function ( conf ) {
    cocoConfig = conf.coco;
  };

var compile =  function ( file, cb ) {
  var output, error;

  if ( !compilerLib ) {
    compilerLib = require( "coco" );
  }

  try {
    var compilerConfig = _.extend( {}, cocoConfig );
    output = compilerLib.compile( file.inputFileText, compilerConfig );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  base: "coco",
  compilerType: "javascript",
  defaultExtensions: ["co", "coco"],
  init: init,
  compile: compile,
  setCompilerLib: setCompilerLib
};