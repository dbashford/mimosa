"use strict";

var fs = require( "fs" );

var _read = function( config, options, next ) {

  if ( options.files && options.files.length ) {

    var i = 0;
    var done = function() {
      if ( ++i === options.files.length ) {
        next();
      }
    };

    options.files.forEach( function( file ) {
      if ( !file.inputFileName ) {
        return done();
      }

      fs.readFile( file.inputFileName, function( err, text ) {
        if ( err ) {
          config.log.error("Failed to read file [[ " + file.inputFileName + " ]], " + err , { exitIfBuild: true } );
        } else {
          if ( options.isJavascript || options.isCSS || options.isTemplate ) {
            text = text.toString();
          }
          file.inputFileText = text;
        }
        done();
      });
    });

  } else {
    next();
  }
};

exports.registration = function( config, register ) {
  var e = config.extensions;

  register(
    ["add", "update", "buildFile"],
    "read",
    _read,
    [].concat.apply( e.javascript, e.copy, e.misc )
  );

  register(
    ["add", "update", "remove", "buildExtension"],
    "read",
    _read,
    [].concat.apply( e.css, e.template )
  );
};