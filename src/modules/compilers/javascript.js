"use strict";

var logger = require( "logmimosa" )
  , deprecateMessageShown = false
  ;

var _determineOutputFile = function( config, options, next ) {
  if ( options.files && options.files.length ) {
    options.destinationFile = function( fileName ) {
      var baseCompDir = fileName.replace( config.watch.sourceDir, config.watch.compiledDir );
      return baseCompDir.substring( 0, baseCompDir.lastIndexOf( "." ) ) + ".js";
    };

    for ( var i = 0, len = options.files.length; i < len; i++ ) {
      var file = options.files[i];
      file.outputFileName = options.destinationFile( file.inputFileName );
    }
  }
  next();
};

var __sourceMap = function( file, output, sourceMap ) {
  // already has source map?
  if ( output.indexOf( "sourceMappingURL=" ) > -1 ) {
    return output;
  }

  // parse source map to object
  if ( typeof sourceMap === "string" ) {
    sourceMap = JSON.parse( sourceMap );
  }

  if ( !sourceMap.sources ) {
    sourceMap.sources = [];
  }

  sourceMap.sources[0] = file.inputFileName;
  sourceMap.sourcesContent = [file.inputFileText];
  sourceMap.file = file.outputFileName;

  var base64SourceMap = new Buffer( JSON.stringify( sourceMap ) ).toString( "base64" );
  var datauri = "data:application/json;base64," + base64SourceMap;
  return output + "\n//# sourceMappingURL=" + datauri + "\n";
};

function JSCompiler( config, _compiler ) {
  this.compiler = _compiler;
}

JSCompiler.prototype.registration = function( config, register ) {
  var exts = this.compiler.extensions( config );

  register(
    ["add", "update", "remove", "cleanFile", "buildFile"],
    "init",
    _determineOutputFile,
    exts );

  register(
    ["add", "update", "buildFile"],
    "compile",
    this._compile.bind( this ),
    exts );
};

JSCompiler.prototype._compile = function( config, options, next ) {
  if ( options.files && options.files.length ) {
    for ( var i = 0, len = options.files.length; i < len; i++ ) {
      var file = options.files[i];
      file.isVendor = options.isVendor;

      if ( logger.isDebug() ) {
        logger.debug( "Calling compiler function for compiler [[ " + this.compiler.name + " ]]" );
      }

      this.compiler.compile( config, file, function( err, output, sourceMap, deprecated ) {

        // deprecated compilerConfig with 3.0
        if ( arguments.length === 4 ) {
          if ( !deprecateMessageShown ) {
            logger.info( this.compiler.name + " compiler is using deprecated compile return, please notify module author." );
            deprecateMessageShown = true;
          }
          sourceMap = deprecated;
        }

        if ( err ) {
          logger.error( "File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err, { exitIfBuild:true } );
        } else {
          if ( sourceMap ) {
            output = __sourceMap( file, output, sourceMap );
          }
          file.outputFileText = output;
        }

        if ( i === options.files.length - 1 ) {
          next();
        }
      }.bind( this ));
    }
  } else {
    next();
  }
};

module.exports = JSCompiler;
