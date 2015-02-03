"use strict";

var fs = require( "fs" );

var _delete = function( config, options, next ) {

  // has no discernable output file
  if ( !options.destinationFile ) {
    return next();
  }

  var fileName = options.destinationFile( options.inputFile );
  fs.exists( fileName, function( exists ) {
    if ( !exists ) {
      return next();
    }

    fs.unlink( fileName, function( err ) {
      if ( err ) {
        config.log.error( "Failed to delete file [[ " + fileName + " ]]" );
      } else {
        config.log.success( "Deleted file [[ " + fileName + " ]]", options );
      }
      next();
    });
  });
};

exports.registration = function( config, register ) {
  var e = config.extensions;
  register(
    ["remove", "cleanFile"],
    "delete",
    _delete,
    [].concat.apply(e.javascript, e.css, e.copy, e.misc)
  );
};