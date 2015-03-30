"use strict";

var logger = require( "logmimosa" );

function MiscCompiler( config, _compiler ) {
  this.extensions = _compiler.extensions( config );
  this.compiler = _compiler;
}

MiscCompiler.prototype.registration = function( config, register ) {
  register(
    ["add", "update", "remove", "cleanFile", "buildFile"],
    "init",
    this._determineOutputFile.bind( this ),
    this.extensions );

  register(
    ["add", "update", "buildFile"],
    "compile",
    this.compiler.compile,
    this.extensions );
};

MiscCompiler.prototype._determineOutputFile = function( config, options, next ) {
  // if destinationFile is already there,
  // ignore all this, don't want misc compilers
  // overwriting compiler with same extension
  if ( options.files && options.files.length && !options.destinationFile ) {

    if ( this.compiler.compilerType === "copy" ) {
      options.destinationFile = function( fileName ) {
        return fileName.replace( config.watch.sourceDir, config.watch.compiledDir );
      };

      options.files.forEach( function( file ) {
        file.outputFileName = options.destinationFile( file.inputFileName );
      });
    } else {
      if ( this.compiler.determineOutputFile ) {
        this.compiler.determineOutputFile( config, options );
      } else {
        if ( logger.isDebug() ) {
          logger.debug( "compiler [[ " + this.compiler.name + " ]] does not have determineOutputFile function." );
        }
      }
    }
  }

  next();
};

module.exports = MiscCompiler;
