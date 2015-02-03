"use strict";

// This module removes empty directories after the files
// have been removed from them

var fs = require( "fs" )
  , path = require( "path" )
  , _ = require( "lodash" )
  , wrench = require( "wrench")
  ;

var _clean = function( config, options, next ) {

  var dir = config.watch.compiledDir;
  var directories = wrench.readdirSyncRecursive(dir).filter( function( f ) {
    return fs.statSync(path.join(dir, f)).isDirectory();
  });

  if ( directories.length === 0 ) {
    return next();
  }

  var doneCount = 0;
  var done = function(){
    if ( ++doneCount === directories.length ) {
      next();
    }
  };

  _.sortBy( directories, "length" ).reverse().forEach( function( dir ) {
    var dirPath = path.join( config.watch.compiledDir, dir );
    if( fs.existsSync( dirPath ) ) {
      try {
        fs.rmdirSync( dirPath );
        config.log.success( "Deleted empty directory [[ " + dirPath + " ]]" );
      } catch ( err ) {
        if ( err.code === "ENOTEMPTY" ) {
          config.log.info( "Unable to delete directory [[ " + dirPath + " ]] because directory not empty." );
        } else {
          config.log.error( "Unable to delete directory, [[ " + dirPath + " ]]" );
          config.log.error( err );
        }
      }
    }
    done();
  });
};

exports.registration = function( config, register ) {
  register( ["postClean"], "complete", _clean );
};