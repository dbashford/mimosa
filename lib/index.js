var program = require( 'commander' )
  , logger =  require( 'logmimosa' )
  , version = require( '../package.json' ).version;

program.version( version );
require( './command/new' )( program );
require( './command/watch' )( program );
require( './command/config' )( program );
require( './command/build' )( program );
require( './command/clean' )( program );
require( './command/external' )( program );
require( './command/module/install' )( program );
require( './command/module/uninstall' )( program );
require( './command/module/list') ( program );
require( './command/module/config' )( program );

program.on( '--help', function() {
  console.log( "  Node Options (these will be passed through to the node process that runs Mimosa):");
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

if ( ( process.argv.length === 2 ) || ( process.argv.length > 2 && process.argv[2] === '--help' ) ) {
  process.argv[2] = '--help';
} else {
  program.command( '*' ).action( function ( arg ) {
    if ( arg ) {
      logger.red( "  " + arg + " is not a valid command." );
    }
    process.argv[2] = '--help';
    program.parse( process.argv );
  });
}

program.parse( process.argv );