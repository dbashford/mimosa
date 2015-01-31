"use strict";

var fileUtils = require( "../../util/file" );

var _setFileFlags = function( config, options ) {
  var exts = config.extensions;
  var ext = options.extension;

  options.isJavascript = false;
  options.isCSS = false;
  options.isVendor = false;
  options.isJSNotVendor = false;
  options.isCopy = false;
  options.isTemplate = false;

  if ( exts.template.indexOf( ext ) > -1 ) {
    options.isTemplate = true;
    options.isJavascript = true;
    options.isJSNotVendor = true;
  }

  if ( exts.copy.indexOf( ext ) > -1 ) {
    options.isCopy = true;
  }

  if (
       exts.javascript.indexOf( ext ) > -1 ||
       ( options.inputFile && fileUtils.isJavascript( options.inputFile ) )
    ){
    options.isJavascript = true;
    if ( options.inputFile ) {
      options.isVendor = fileUtils.isVendorJS( config, options.inputFile );
      options.isJSNotVendor = !options.isVendor;
    }
  }

  if (
       exts.css.indexOf( ext ) > -1 ||
       ( options.inputFile && fileUtils.isCSS( options.inputFile ) )
    ){
    options.isCSS = true;
    if ( options.inputFile ) {
      options.isVendor = fileUtils.isVendorCSS( config, options.inputFile );
    }
  }
};

var _initSingleAsset = function( config, options, next ) {
  _setFileFlags( config, options );

  options.files = [{
    inputFileName:options.inputFile,
    outputFileName:null,
    inputFileText:null,
    outputFileText:null
  }];

  next();
};

var _initMultiAsset = function( config, options, next ) {
  _setFileFlags( config, options );
  options.files = [];
  next();
};

exports.registration = function( config, register ) {
  var e = config.extensions;
  register(
    ["add", "update", "remove", "cleanFile", "buildExtension"],
    "init",
    _initMultiAsset,
    [].concat.apply(e.template, e.css)
  );

  register(
    ["add", "update", "remove", "cleanFile", "buildFile"],
    "init",
    _initSingleAsset,
    [].concat.apply(e.javascript, e.copy, e.misc)
  );
};