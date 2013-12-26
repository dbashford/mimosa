"use strict";

var fs = require('fs')
  , path = require('path')
  , spawn = require('child_process').spawn
  , exec = require('child_process').exec
  , _ = require('lodash')
  , logger = require('logmimosa')
  , importRegex = /@import ['"](.*)['"]/g
  , runSass = 'sass'
  , hasSASS
  , hasCompass
  , compilerLib = null
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  }
  , isInclude = function ( fileName, includeToBaseHash ) {
    return ( includeToBaseHash[fileName] || path.basename( fileName ).charAt( 0 ) === '_' );
  }
  , getImportFilePath = function ( baseFile, importPath ) {
    return path.join( path.dirname( baseFile ), importPath.replace(/(\w+\.|[\w-]+$)/, '_$1') );
  };

var _doRubySASSChecking = function () {
  logger.debug( "Checking if Compass/SASS is available" );
  exec( 'compass --version', function ( error, stdout, stderr ) {
    hasCompass = !error;
  });

  if ( process.platform === 'win32' ) {
    runSass = 'sass.bat';
  }

  exec( runSass + " --version", function ( error, stdout, stderr ) {
    hasSASS = !error;
  });
};

var _compileRuby = function ( file, config, options, done ) {
  var text = file.inputFileText
    , fileName = file.inputFileName
    , result = ''
    , error = null
    , compilerOptions = [ '--stdin', '--load-path', config.watch.sourceDir, '--load-path', path.dirname(fileName), '--no-cache' ];

  if ( logger.isDebug ) {
    logger.debug( "Beginning Ruby compile of SASS file [[ " + fileName + " ]]" );
  }

  if ( hasCompass ) {
    compilerOptions.push( '--compass' );
  }

  if ( /\.scss$/.test( fileName ) ) {
    compilerOptions.push( '--scss' );
  }

  var sass = spawn( runSass, compilerOptions );
  sass.stdin.end( text );
  sass.stdout.on( 'data', function ( buffer ) {
    result += buffer.toString();
  });
  sass.stderr.on( 'data', function ( buffer ) {
    if ( !error ) {
      error = '';
    }
    error += buffer.toString();
  });

  sass.on( 'exit', function ( code ) {
    if ( logger.isDebug ) {
      logger.debug( "Finished Ruby SASS compile for file [[ " + fileName + " ]], errors? " + !!error);
    }
    done( error, result );
  });
};

var _preCompileRubySASS = function ( file, config, options, done ) {
  if ( hasCompass !== undefined && hasSASS !== undefined && hasSASS ) {
    return _compileRuby( file, config, options, done );
  }

  if ( hasSASS !== undefined && !hasSASS ) {
    var msg = "You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or provide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.";
    return done( msg, '' );
  }

  var compileOnDelay = function() {
    if ( hasCompass !== undefined && hasSASS !== undefined ) {
      if ( hasSASS ) {
        _compileRuby( file, config, options, done );
      } else {
        var msg = "You have SASS files but do not have Ruby SASS available. Either install Ruby SASS or provide compilers.libs.sass:require('node-sass') in the mimosa-config to use node-sass.";
        return done( msg, '' );
      }
    } else {
      setTimeout( compileOnDelay, 100 );
    }
  };
  compileOnDelay();
};

var _compileNode = function ( file, config, options, done ) {
  if ( logger.isDebug ) {
    logger.debug( "Beginning node compile of SASS file [[ " + file.inputFileName + " ]]" );
  }

  var finished = function ( error, text ) {
    logger.debug ( "Finished node compile for file [[ " + file.inputFileName + " ]], errors? " + !!error );
    done( error, text );
  };

  compilerLib.render({
    data: file.inputFileText,
    includePaths: [ config.watch.sourceDir, path.dirname( file.inputFileName ) ],
    success: function (css) {
      finished( null, css );
    },
    error: function ( error ) {
      finished( error, '' );
    }
  });
};

var init = function ( config ) {
  if ( !config.compilers.libs.sass ) {
    _doRubySASSChecking();
  }
};

var compile = function ( file, config, options, done ) {
  if ( config.compilers.libs.sass ) {
    _compileNode( file, config, options, done );
  } else {
    _preCompileRubySASS( file, config, options, done );
  }
};

var determineBaseFiles = function ( allFiles ) {
  var baseFiles = allFiles.filter( function ( file ) {
    return( !isInclude( file, {} ) && file.indexOf('compass') < 0 );
  });

  if ( logger.isDebug ) {
    logger.debug("Base files for SASS are:\n" + baseFiles.join('\n'));
  }

  return baseFiles;
};

module.exports = {
  base: "sass",
  compilerType: "css",
  defaultExtensions: ["scss", "sass"],
  importRegex: importRegex,
  init: init,
  compile: compile,
  isInclude: isInclude,
  getImportFilePath: getImportFilePath,
  determineBaseFiles: determineBaseFiles,
  setCompilerLib: setCompilerLib
};