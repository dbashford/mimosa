var logger = require( "logmimosa" );

var _ignoreFunct = function( config ) {
  return function ( name ) {

    // comes in as [name, stats]
    name = name[0];

    if ( config.watch.excludeRegex ) {
      if ( name.match( config.watch.excludeRegex) ) {
        logger.debug( "Ignoring file [[ " + name + " ]], matches exclude regex" );
        return true;
      }
    }

    if ( config.watch.exclude ) {
      if ( config.watch.exclude.indexOf( name ) > -1 ) {
        logger.debug( "Ignoring file [[ " + name + " ]], matches exclude string path" );
        return true;
      }
    }

    return false;
  };
};

exports.watchConfig = function ( config, persistent ) {
  return {
    ignored: _ignoreFunct( config ),
    persistent: persistent,
    interval: config.watch.interval,
    binaryInterval: config.watch.binaryInterval,
    usePolling: config.watch.usePolling
  };
};