"use strict";

var path = require( "path" )
  , fs = require( "fs" )
  , _ = require( "lodash" )
  , logger = require( "logmimosa" )
  , JavaScriptCompiler = require( "./javascript" )
  , CSSCompiler = require( "./css" )
  , TemplateCompiler = require( "./template" )
  , MiscCompiler = require( "./misc" )
  , templateLibrariesBeingUsed = 0
  ;

exports.compilers = [];

var _testDifferentTemplateLibraries = function( config, options, next ) {
  if ( options.files && options.files.length ) {
    if ( typeof config.template.outputFileName === "string" ) {
      if ( ++templateLibrariesBeingUsed === 2 ) {
        logger.error( "More than one template library is being used, but multiple template.outputFileName entries not found." +
          " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" +
          " template output for one of the libraries." );
      }
    }
  }
  next();
};


// Process compilers
// will build master list of extensions for project run
// will resort compilers so they are in the right processing order
exports.setupCompilers = function( config ) {

  // TODO: make compiler management a class
  // this is reset in the event it is called
  // multiple times within the same process
  if ( exports.compilers.length ) {
    exports.compilers = [];
  }

  // iterate over list of installed modules and
  // assemble list of compilers
  var modNames = Object.keys( config.installedModules );
  for ( var i = 0, len = modNames.length; i < len; i++) {
    var mod = config.installedModules[modNames[i]];
    // is compiler?
    if ( mod.compilerType ) {
      if ( logger.isDebug() ) {
        logger.debug( "Found compiler [[ " + mod.name + " ]], adding to array of compilers" );
      }
      exports.compilers.push( mod );
    }
  }

  for ( var k = 0, klen = exports.compilers.length; k < klen; k++ ) {
    var compiler = exports.compilers[k];
    var exts = compiler.extensions( config );
    config.extensions[compiler.compilerType] = config.extensions[compiler.compilerType].concat( exts );
  }

  // make extension lists unique
  var types = Object.keys( config.extensions );
  for ( var l = 0, llen = types.length; l < llen; l++) {
    var type = types[l];
    config.extensions[type] = _.uniq( config.extensions[type] );
  }

  // sort copy and misc to the end of compilers list
  // as they are not to override other compilers,
  // for instance if two compilers both register
  // for same extension
  // TODO, consider remove resortCompilers
  if ( config.resortCompilers ) {
    var backloadCompilers = ["copy", "misc"];
    var copyMisc = _.remove( exports.compilers, function( comp ) {
      return backloadCompilers.indexOf( comp.compilerType ) > -1;
    });
    exports.compilers = exports.compilers.concat( copyMisc );
  }
};

var _determineCompilerType = function( compilerType ) {
  switch ( compilerType ) {
    case "copy":
      return MiscCompiler;
    case "misc":
      return MiscCompiler;
    case "javascript":
      return JavaScriptCompiler;
    case "template":
      return TemplateCompiler;
    case "css":
      return CSSCompiler;
  }
};

exports.registration = function( config, register ) {
  for ( var i = 0, len = exports.compilers.length; i < len; i++ ) {
    var compiler = exports.compilers[i];
    var CompilerClass = _determineCompilerType( compiler.compilerType );
    var compilerInstance = new CompilerClass( config, compiler );
    compilerInstance.name = compiler.name;
    compilerInstance.registration( config, register );
    if ( compiler.registration ) {
      compiler.registration( config, register );
    }
  }

  if ( config.template ) {
    register( ["buildExtension"], "complete", _testDifferentTemplateLibraries, config.extensions.template );
  }
};

exports.defaults = function() {
  return {
    resortCompilers: true,
    template: {
      writeLibrary: true,
      wrapType: "amd",
      commonLibPath: null,
      nameTransform:"fileName",
      outputFileName: "javascripts/templates"
    }
  };
};

exports.validate = function( config, validators ) {
  var errors = [];

  validators.ifExistsIsBoolean( errors, "resortCompilers", config.resortCompilers );

  if ( validators.ifExistsIsObject( errors, "template config", config.template ) ) {
    validators.ifExistsIsBoolean( errors, "template.writeLibrary", config.template.writeLibrary );

    if ( config.template.output && config.template.outputFileName ) {
      delete config.template.outputFileName;
    }

    if ( validators.ifExistsIsString( errors, "template.wrapType", config.template.wrapType ) ) {
      if ( ["common", "amd", "none"].indexOf( config.template.wrapType ) == -1 ) {
        errors.push( "template.wrapType must be one of: 'common', 'amd', 'none'" );
      }
    }

    if ( config.template.nameTransform != null ) {
      if ( typeof config.template.nameTransform == "string" ) {
        if ( ["fileName","filePath"].indexOf( config.template.nameTransform ) == -1 ) {
          errors.push( "config.template.nameTransform valid string values are filePath or fileName" );
        }
      } else if ( typeof config.template.nameTransform == "function" || config.template.nameTransform instanceof RegExp ) {
        // do nothing
      } else {
        errors.push( "config.template.nameTransform property must be a string, regex or function" );
      }
    }

    if ( config.template.outputFileName ) {
      config.template.output = [{
        folders: [""],
        outputFileName: config.template.outputFileName
      }];
    }

    if ( validators.ifExistsIsArrayOfObjects( errors, "template.output", config.template.output ) ) {
      var fileNames = [];

      for ( var k = 0, klen = config.template.output.length; k < klen; k++ ) {
        var outputConfig = config.template.output[k];

        if ( validators.isArrayOfStringsMustExist( errors, "template.output.folders", outputConfig.folders ) ) {
          if ( outputConfig.folders.length === 0 ) {
            errors.push( "template.output.folders must have at least one entry" );
          } else {
            var newFolders = [];
            for ( var l = 0, llen = outputConfig.folders.length; l < llen; l++ ) {
              var folder = path.join( config.watch.sourceDir, outputConfig.folders[l] );
              if ( !fs.existsSync( folder ) ) {
                errors.push( "template.output.folders must exist, folder resolved to [[ " + folder + " ]]" );
              }
              newFolders.push( folder );
            }
            outputConfig.folders = newFolders;
          }
        }

        if ( outputConfig.outputFileName ) {
          var fName = outputConfig.outputFileName;
          if ( typeof fName == "string" ) {
            fileNames.push( fName );
          } else if ( typeof fName == "object" && !Array.isArray( fName ) ) {
            var keys = Object.keys( fName );
            for ( var i = 0, len = keys.length; i < keys; i++ ) {
              var tComp = keys[i];
              fileNames.push( fName[tComp] );
            }
          } else {
            errors.push( "template.outputFileName must be an object or a string." );
          }
        } else {
          errors.push( "template.output.outputFileName must exist for each entry in array." );
        }
      }

      if ( fileNames.length !== _.uniq( fileNames ).length ) {
        errors.push( "template.output.outputFileName names must be unique." );
      }
    }
  }

  return errors;
};