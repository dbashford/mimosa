var retrieveConfig = function( opts, callback ) {
  var logger = require( "logmimosa" );

  if ( opts.mdebug ) {
    logger.setDebug();
    process.env.DEBUG = true;
  }

  var configurer = require( "../util/configurer" );
  configurer( opts, function( config, mods ) {
    if ( opts.buildFirst ) {
      var Cleaner = require( "../util/cleaner" )
        , Watcher = require( "../util/watcher" )
        ;

      config.isClean = true;
      new Cleaner( config, mods, function() {
        config.isClean = false;
        new Watcher( config, mods, false, function() {
          logger.success( "Finished build" );
          callback( config );
        });
      });
    } else {
      callback( config );
    }
  });
};

module.exports = function( program ) {
  var modules = require( "../modules" )
    , modsWithCommands = modules.modulesWithCommands()
    , logger = require( "logmimosa" )
    ;

  for( var i = 0, len = modsWithCommands.length; i < len; i++) {
    modsWithCommands[i].registerCommand( program, logger, retrieveConfig );
  }
};
