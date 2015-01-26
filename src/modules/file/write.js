"use strict";

var _write = function( config, options, next ) {
  if ( options.files && options.files.length ) {

    var processed = 0;
    var done = function() {
      if ( ++processed === options.files.length ) {
        next();
      }
    };

    var fileUtils = require( "../../util/file" );
    for ( var i = 0; i < options.files.length; i++ ) {
      var file = options.files[i];

      // If the outputText is null/undef or there is no name set then all done
      if ( ( file.outputFileText !== "" && !file.outputFileText ) || !file.outputFileName ) {
        return done();
      }

      // if the output text is empty, let user know
      if ( file.outputFileText === "" ) {
        config.log.warn( "File [[ " + file.inputFileName + " ]] is empty." );
      }

      fileUtils.writeFile( file.outputFileName, file.outputFileText, function( err ) {
        if ( err ) {
          config.log.error( "Failed to write new file [[ " + file.outputFileName + " ]], Error: " + err, {exitIfBuild:true});
        } else {
          config.log.success( "Wrote file [[ " + file.outputFileName + " ]]", options );
        }
        done();
      });
    }
  } else {
    next();
  }
};

exports.registration = function( config, register ) {
  var e = config.extensions;
  register(
    ["add", "update", "remove", "buildExtension"],
    "write",
    _write,
    [].concat.apply( e.template, e.css )
  );

  register(
    ["add", "update", "buildFile"],
    "write",
    _write,
    [].concat.apply( e.javascript, e.copy, e.misc )
  );
};