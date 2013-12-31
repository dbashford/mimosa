"use strict";

var fs = require( 'fs' )
  , path = require( 'path' )
  , logger = require( 'logmimosa' )
  , handlebars = null
  , ember = false
  , config = {}
  , init = function ( conf ) {
    config = conf;
  }
  , regularBoilerplate = "if (!Handlebars) {\n  console.log(\"Handlebars library has not been passed in successfully\");\n  return;\n}\n\nvar template = Handlebars.template, templates = {};\nHandlebars.partials = templates;\n"
  , emberBoilerplate = "var template = Ember.Handlebars.template, templates = {};\n";

var _determineHandlebars = function () {
  var hbs;

  ember = config.template.handlebars.ember.enabled;

  if ( config.compilers.libs.handlebars ) {
    hbs = config.compilers.libs.handlebars;
  } else {
    hbs = require( 'handlebars' );
  }

  if ( ember ) {
    var ec = require( './resources/ember-comp' );
    handlebars = ec.makeHandlebars( hbs );
  } else {
    handlebars = hbs;
  }
};

var prefix = function ( config, libraryPath ) {
  var boilerplate = emberBoilerplate;
  if ( !ember ) {
    boilerplate = regularBoilerplate;
  }

  if ( config.template.wrapType === 'amd' ) {
    logger.debug( "Building Handlebars template file wrapper" );
    var jsDir = path.join( config.watch.sourceDir, config.watch.javascriptDir )
      , possibleHelperPaths = []
      , helperPaths
      , defineString
      , defines = []
      , params = [];

    // build list of possible paths for helper files
    config.extensions.javascript.forEach( function( ext ) {
      config.template.handlebars.helpers.forEach( function( helperFile ) {
        possibleHelperPaths.push( path.join( jsDir, helperFile + "." + ext ) );
      });
    });

    // filter down to just those that exist
    helperPaths = possibleHelperPaths.filter( function ( p) {
      return fs.existsSync( p );
    });

    // set up initial define dependency array and the array export parameters
    if ( ember ) {
      defines.push( "'" + config.template.handlebars.ember.path + "'" );
      params.push( "Ember" );
    } else {
      defines.push( "'" + libraryPath + "'" );
      params.push( "Handlebars" );
    }

    // build proper define strings for each helper path
    helperPaths.forEach( function( helperPath ) {
      var helperDefine = helperPath.replace( config.watch.sourceDir, '' )
        .replace( /\\/g, '/' )
        .replace( /^\/?\w+\/|\.\w+$/g, '' );
      defines.push( "'" + helperDefine + "'" );
    });

    defineString = defines.join( ',' );

    if ( logger.isDebug ) {
      logger.debug( "Define string for Handlebars templates [[ " + defineString + " ]]" );
    }

    return "define([" + defineString + "], function (" + (params.join(',')) + "){\n  " + boilerplate;
  } else {
    if ( config.template.wrapType === 'common' ) {
      if ( ember ) {
        return "var Ember = require('" + config.template.commonLibPath + "');\n" + boilerplate;
      } else {
        return "var Handlebars = require('" + config.template.commonLibPath + "');\n" + boilerplate;
      }
    }
  }

  return boilerplate;
};

var suffix = function (config) {
  if ( config.template.wrapType === 'amd' ) {
    return "return templates; });";
  } else {
    if ( config.template.wrapType === "common" ) {
      return "\nmodule.exports = templates;";
    }
  }

  return "";
};

var compile = function (file, cb) {
  var output, error;

  if ( !handlebars) {
    _determineHandlebars();
  }

  try {
    output = handlebars.precompile( file.inputFileText );
    output = "template(" + output.toString() + ")";
    if ( ember) {
      output = "Ember.TEMPLATES['" + file.templateName + "'] = " + output;
    }
  } catch ( err ) {
    error = err;
  }

  cb( error, output );
};

module.exports = {
  name: "handlebars",
  compilerType: "template",
  defaultExtensions: ["hbs", "handlebars"],
  clientLibrary: path.join( __dirname, "client", "handlebars.js" ),
  compile: compile,
  init: init,
  suffix: suffix,
  prefix: prefix
};