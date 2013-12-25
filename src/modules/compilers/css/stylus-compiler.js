"use strict";

var fs = require('fs')
  , path = require('path')
  , _ = require('lodash')
  , logger = require('logmimosa')
  , importRegex = /@import[\s\t]*[\(]?[\s\t]*['"]?([a-zA-Z0-9*\/\.\-\_]*)[\s\t]*[\n;\s'")]?/g
  , compilerLib = null
  , libName = "stylus"
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  }
  , getImportFilePath = function ( baseFile, importPath ) {
    return path.join( path.dirname( baseFile ), importPath );
  };

var compile = function (file, config, options, done) {
  var stylusSetup
    , text = file.inputFileText
    , fileName = file.inputFileName
    , cb = function ( err, css ) {
      if ( logger.isDebug ) {
        logger.debug( "Finished Stylus compile for file [[ " + fileName + " ]], errors? " + !!err );
      }
      done( err, css );
    };

  if ( !compilerLib ) {
    compilerLib = require( libName );
  }

  stylusSetup = compilerLib( text )
    .include( path.dirname( fileName ) )
    .include( config.watch.sourceDir )
    .set( 'compress', false )
    .set( 'filename', fileName )
    .set( 'include css', true );
    //.set('firebug', not config.isOptimize)
    //.set('linenos', not config.isOptimize and not config.isBuild)

  if ( config.stylus.url ) {
    stylusSetup.define( 'url', compilerLib.url( config.stylus.url ) );
  }

  if ( config.stylus.includes ) {
    config.stylus.includes.forEach( function( inc ) {
      stylusSetup.include( inc );
    });
  }

  if ( config.stylus.resolvedUse ) {
    config.stylus.resolvedUse.forEach( function( ru ) {
      stylusSetup.use( ru );
    });
  }

  if ( config.stylus.import ) {
    config.stylus.import.forEach( function ( imp ) {
      stylusSetup.import( imp );
    });
  }

  Object.keys(config.stylus.define).forEach( function( define ) {
    stylusSetup.define( define, config.stylus.define[define] );
  });

  if ( logger.isDebug ) {
    logger.debug( "Compiling Stylus file [[ " + fileName + " ]]" );
  }

  stylusSetup.render( cb );
};

var determineBaseFiles = function (allFiles) {
  var imported = []
    , baseFiles;

  allFiles.forEach( function( file ) {
    var imports = fs.readFileSync( file, 'utf8' ).match( importRegex );
    if ( imports ) {
      imports.forEach( function( anImport ) {
        importRegex.lastIndex = 0;
        var importPath = importRegex.exec( anImport )[1];
        var fullImportPath = path.join( path.dirname( file ), importPath );
        allFiles.some( function( fullFilePath ) {
          if (fullFilePath.indexOf( fullImportPath ) === 0) {
            fullImportPath += path.extname( fullFilePath );
            return true;
          }
        });
        imported.push( fullImportPath );
      });
    }
  });

  baseFiles = _.difference( allFiles, imported );
  if ( logger.isDebug ) {
    logger.debug( "Base files for Stylus are:\n" + baseFiles.join('\n'));
  }
  return baseFiles;
};

module.exports = {
  base: "stylus",
  type: "css",
  defaultExtensions: ["styl"],
  canFullyImportCSS: true,
  importRegex: importRegex,
  compile: compile,
  determineBaseFiles: determineBaseFiles,
  getImportFilePath: getImportFilePath,
  setCompilerLib: setCompilerLib
};