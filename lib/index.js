// If just looking for version, spit it out and be done
if ( process.argv.indexOf( "--version" ) === 2 ) {
  var version = require( '../package.json' ).version;
  console.log( version );
  return;
}

var logger =  require( 'logmimosa' )
  , program = require( 'commander' )
  , modCommandsAdded = false;

var modCommands = function() {
  if ( !modCommandsAdded ) {
    require( './command/module/install' )( program );
    require( './command/module/uninstall' )( program );
    require( './command/module/list') ( program );
    require( './command/module/config' )( program );
  }
  modCommandsAdded = true;
};

var makeTopLevelHelp = function() {
  process.argv[2] = '--help';
  modCommands();
  program.on( '--help', function() {
    console.log( "  Node Options (these will be passed through to the node process that runs Mimosa):");
    console.log( '    --nolazy, turns off lazy compilation, forcing v8 to do a full compile of the code.');
    console.log( '    --debug, useful when you are not going to debug node.js right now, but you want to debug it later.');
    console.log( '    --debug-brk, allows you to debug the code executed on start');
    console.log( '    --expose-gc, expose gc extension');
    console.log( '    --gc, expose gc extension');
    console.log( '    --gc-global, gc forced by flags');
    console.log( '    --harmony, enable all harmony features (except typeof)');
    console.log( '    --harmony-collections, enable harmony collections (sets, maps, and weak maps)');
    console.log( '    --harmony-generators, enable harmony proxies');
    console.log( '    --harmony-proxies, enable harmony proxies');
    console.log( '    --prof, Log statistical profiling information (implies --log-code)');
    console.log( "\n" );
  });
};

require( './command/watch' )( program );
require( './command/config' )( program );
require( './command/build' )( program );
require( './command/clean' )( program );
require( './command/external' )( program );

// if someone just types "mimosa", treat it as --help.
if ( process.argv.length === 2 || ( process.argv.length > 2 && ( process.argv[2] === '--help' || process.argv[2] === '-h') ) ) {
  makeTopLevelHelp();
} else {
  program.command( '*' ).action( function ( arg ) {
    if ( arg ) {
      logger.red( "  " + arg + " is not a valid command." );
    }
    makeTopLevelHelp();
    program.parse( process.argv );
  });

  if ( !modCommandsAdded ) {
    process.argv.forEach( function( arg ) {
      if ( arg.indexOf( "mod:" ) === 0 ) {
        modCommands();
      }
    });
  }
}

// var cleanUpProcesses = function() {
//   var psTree = require( 'ps-tree' );
//   psTree( process.pid, function( err, children ) {
//     children.forEach( function( c ) {
//       process.kill( c.PID );
//     });
//   });
// };
//
// // ensure cleanup of mimosa related stuff on sigterm
// process.on( 'SIGTERM', cleanUpProcesses).on( 'SIGINT', cleanUpProcesses );

program.parse( process.argv );