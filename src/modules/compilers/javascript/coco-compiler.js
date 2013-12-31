"use strict";

var _ = require( 'lodash' )
  , compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var compile =  function ( mimosaConfig, file, cb ) {
  var output, error;

  if ( !compilerLib ) {
    compilerLib = require( "coco" );
  }

  try {
    var compilerConfig = _.extend( {}, mimosaConfig.coco );
    output = compilerLib.compile( file.inputFileText, compilerConfig );
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  name: "coco",
  compilerType: "javascript",
  defaultExtensions: ["co", "coco"],
  compile: compile,
  setCompilerLib: setCompilerLib
};