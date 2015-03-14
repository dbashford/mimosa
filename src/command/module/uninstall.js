var deleteMod = function( name, opts ) {
  var path = require( "path" )
    , fs =     require( "fs" )
    , exec = require( "child_process" ).exec
    , logger = require( "logmimosa" )
    , moduleMetadata = require( "../../modules") .installedMetadata
    , currentDir = process.cwd()
    , mimosaPath = path.join( __dirname, "..", "..", ".." )
    ;

  if ( opts.mdebug ) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }

  if ( !name ) {
    var packageJSONPath = path.join( process.cwd(), "package.json" )
      , pack
      ;

    try {
      pack = JSON.parse( fs.readFileSync( packageJSONPath, "utf8" ) );
    } catch ( err ) {
      return logger.error( "Unable to find package.json, or badly formatted", err );
    }

    if ( !pack.name || !pack.version ) {
      return logger.error( "package.json missing either name or version" );
    }

    name = pack.name;
  }

  if ( name.indexOf( "mimosa-" ) !== 0 ) {
    return logger.error( "Can only delete 'mimosa-' prefixed modules with mod:uninstall (ex: mimosa-server)." );
  }

  var found = moduleMetadata.some( function( mod ) {
    return mod.name === name;
  });

  if ( !found ) {
    return logger.error( "Module named [[ " + name + " ]] is not currently installed so it cannot be uninstalled." );
  }

  process.chdir( mimosaPath );
  var uninstallString = "npm uninstall \"" + name + "\" --save";
  exec( uninstallString, function( err, sout, serr ) {
    if ( err ) {
      logger.error( err );
    } else {
      if ( serr ) {
        logger.error( serr );
      }
      logger.success( "Uninstall of [[ " + name + " ]] successful" );
    }

    process.chdir( currentDir );
    process.exit( 0 );
  });
};

var register = function( program ) {
  program
    .command( "mod:uninstall [name]" )
    .option( "-D, --mdebug", "run in debug mode" )
    .description( "uninstall a Mimosa module from your installed Mimosa" )
    .action( deleteMod )
    .on( "--help", function() {
      var logger = require( "logmimosa" );
      logger.green( "  The 'mod:uninstall' command will delete a Mimosa module from your Mimosa install. This does" );
      logger.green( "  not delete anything from any of your projects, but it removes the ability for all projects" );
      logger.green( "  using Mimosa to utilize the removed module. You can retrieve the list of installed modules " );
      logger.green( "  using 'mod:list'.");
      logger.blue( "\n    $ mimosa mod:uninstall mimosa-server\n");
    });
};

module.exports = register;