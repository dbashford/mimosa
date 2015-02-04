"use strict";

var path = require( "path" )
  , fileUtils = require( "../../util/file" )
  , allExtensions
  ;

var _notValidExtension = function( file ) {
  var ext = path.extname( file.inputFileName ).replace( /\./, "" );
  return ( allExtensions.indexOf( ext ) === -1 );
};

// goal is to process files as they come in
// and determine if the file needs to be processed
// and if not, remove it from files array
var _fileNeedsCompiling = function( config, options, next ) {

  if ( options.files && options.files.length ) {
    var doneCount = 0
      , newFiles = []
      ;

    var done = function() {
      if ( ++doneCount === options.files.length ) {
        options.files = newFiles;
        next();
      }
    };

    for ( var i = 0; i < options.files.length; i++ ) {
      var file = options.files[i];

      // if module has asked for recompile to rebuild cached assets
      // or if extension is for file that was placed here, not that originated the workflow
      // like with .css files and CSS proprocessors
      var jsRecompileForced = options.isJavascript && config.__forceJavaScriptRecompile;
      if ( jsRecompileForced || _notValidExtension( file ) ) {
        newFiles.push( file );
        done();
      } else {
        fileUtils.isFirstFileNewer( file.inputFileName, file.outputFileName, function( isNewer ) {
          if ( isNewer ) {
            newFiles.push( file );
          } else {
            if ( config.log.isDebug() ) {
              config.log.debug( "Not processing [[ " + file.inputFileName + " ]] as it is not newer than destination file." );
            }
          }
          done();
        });
      }
    }
  } else {
    next();
  }
};


var _fileNeedsCompilingStartup = function( config, options, next ) {
  // modules have the ability to force recompile on startup
  // often because they have cached data that isn't up to date
  if( config.__forceJavaScriptRecompile && options.isJSNotVendor ) {
    if( config.log.isDebug() ) {
      config.log.debug( "File [[ " + options.inputFile + " ]] NEEDS compiling/copying" );
    }
    next();
  } else {
    _fileNeedsCompiling( config, options, next );
  }
};

exports.registration = function( config, register ) {

  // does not process css/template extensions as those
  // require special attention for bundling
  allExtensions = [].concat.apply(
    config.extensions.javascript, config.extensions.copy );

  register(
    ["buildFile"],
    "beforeRead",
    _fileNeedsCompilingStartup,
    allExtensions
  );

  register(
    ["add", "update"],
    "beforeRead",
    _fileNeedsCompiling,
    allExtensions
  );
};