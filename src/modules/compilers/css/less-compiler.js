"use strict";

var fs = require('fs')
  , path = require('path')
  , _ = require('lodash')
  , logger = require('logmimosa')
  , importRegex = /@import\s+(?:(?:\(less\)|\(css\))\s+?)?['"](.*)['"]/g
  , libName = "less"
  , compilerLib = null
  , getImportFilePath = function ( baseFile, importPath ) {
    return path.join( path.dirname( baseFile ), importPath );
  }
  , setCompilerLib = function ( _compilerLib ) {
    compilerLib = _compilerLib;
  };

var compile = function ( file, config, options, done ) {
  if ( !compilerLib ) {
    compilerLib = require( libName );
  }

  var fileName = file.inputFileName;
  if ( logger.isDebug ) {
    logger.debug( "Compiling LESS file [[ " + fileName + " ]], first parsing..." );
  }

  var parser = new compilerLib.Parser({
    paths: [ config.watch.sourceDir, path.dirname( fileName ) ],
    filename: fileName
  });

  parser.parse( file.inputFileText, function ( error, tree ) {
    var err, result;

    if ( error ) {
      return done( error, null );
    }

    try {
      logger.debug( "...then converting to CSS" );
      result = tree.toCSS();
    } catch ( ex ) {
      err = ex.type + " Error: " + ex.message;
      if ( ex.filename ) {
        err += " in '" + ex.filename + ":" + ex.line + ":" + ex.column + "'";
      }
    }

    if ( logger.isDebug ) {
      logger.debug( "Finished LESS compile for file [[ " + fileName + " ]], errors? " + !!err) ;
    }

    done( err, result );

  });
};

var determineBaseFiles = function ( allFiles ) {
  var imported = [];
  allFiles.forEach( function ( file ) {
    var imports = fs.readFileSync( file, 'utf8' ).match( importRegex );
    if ( !imports ) {
      return;
    }

    imports.forEach( function ( anImport ) {
      importRegex.lastIndex = 0;
      var importPath = importRegex.exec( anImport )[1];
      var fullImportPath = path.join( path.dirname(file), importPath );
      imported.push( fullImportPath );
    });

  });

  var baseFiles = _.difference( allFiles, imported );
  if ( logger.isDebug ) {
    logger.debug( "Base files for LESS are:\n" + baseFiles.join('\n') );
  }
  return baseFiles;
};

module.exports = {
  base: "less",
  type: "css",
  defaultExtensions: ["less"],
  partialKeepsExtension: true,
  canFullyImportCSS: true,
  importRegex: importRegex,
  compile: compile,
  determineBaseFiles: determineBaseFiles,
  getImportFilePath: getImportFilePath,
  setCompilerLib: setCompilerLib
};