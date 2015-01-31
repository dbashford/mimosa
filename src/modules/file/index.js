"use strict";

var init = require( "./init" )
  , beforeRead = require( "./beforeRead" )
  , read = require( "./read" )
  , write = require( "./write" )
  , del = require( "./delete" )
  , clean = require( "./clean" )
  ;

exports.registration = function( config, register ) {
  [init, beforeRead, read, write, del, clean].forEach( function (module) {
    module.registration( config, register );
  });
};