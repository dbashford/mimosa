"use strict";

// This module removes empty directories after the files
// have been removed from them

var fs = require( "fs" )
  , path = require( "path" )
  , _ = require( "lodash" )
  , wrench = require( "wrench")
  ;

// if directory exists then attempt to remove it
// need to scope dirPath
var _removeDirectoryIfExists = function( config, dirPath, done ) {
  return function( exists ) {
    if( exists ) {
      // remove the directory
      fs.rmdir( dirPath, function( err ) {
        if ( err ) {

          // directory not empty, this is ok
          if ( err.code === "ENOTEMPTY" ) {
            config.log.info( "Unable to delete directory [[ " + dirPath + " ]] because directory not empty." );
          } else {
            // unknown error, this is not ok
            config.log.error( "Unable to delete directory, [[ " + dirPath + " ]]" );
            config.log.error( err );
          }
        } else {
          config.log.success( "Deleted empty directory [[ " + dirPath + " ]]" );
        }
        done();
      });
    } else {
      done();
    }
  };
};

var _clean = function( config, options, next ) {
  var dir = config.watch.compiledDir;
  var directories = wrench.readdirSyncRecursive( dir ).filter( function( f ) {
    return fs.statSync( path.join( dir, f ) ).isDirectory();
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

  // sorted directories so deleting those directories with longer
  // names first, if longer names deleted first you'll never
  // attempt to delete a folder that has a deletable folder inside of it
  var sortedDirectories = _.sortBy( directories, "length" ).reverse();
  for ( var i = 0; i < sortedDirectories.length; i++ ) {
    var dirPath = path.join( config.watch.compiledDir, sortedDirectories[i]);
    fs.exists( dirPath, _removeDirectoryIfExists( config, dirPath, done ) );
  }
};

exports.registration = function( config, register ) {
  register( ["postClean"], "complete", _clean );
};