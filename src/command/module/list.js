var logger = require( "logmimosa" );

var printResults = function( mods, opts ) {
  var color  = require( "ansi-color" ).set
    , moduleMetadata = require( "../../modules" ).installedMetadata
    , verbose = opts.verbose
    , installed = opts.installed
    , longestModName = 0
    , ownedMods = []
    ;

  for( var i = 0, len = mods.length; i <  len; i++ ) {
    var mod = mods[i];
    mod.installed= "";

    if ( mod.name.length > longestModName ) {
      longestModName = mod.name.length;
    }

    for ( var k = 0, lenk = moduleMetadata.length; k < lenk; k++) {
      var m = moduleMetadata[k];
      if ( m.name === mod.name ) {
        if ( mod.version === m.version ) {
          mod.installed = m.version;
        } else {
          mod.installed = color( m.version, "red" );
          mod.site = color( "      " + mod.site, "green+bold" );
        }
        ownedMods.push( mod );
      }
    }
  }

  mods = mods.filter( function( mod ) {
    for ( var l = 0, lenl = ownedMods.length; l < lenl; l++ ) {
      var owned = ownedMods[l];
      if ( owned.name === mod.name ) {
        return false;
      }
    }
    return true;
  });

  if ( installed ) {
    logger.green( "  The following is a list of the Mimosa modules currently installed.\n" );
    mods = ownedMods;
  } else {
    logger.green( "  The following is a list of the Mimosa modules in NPM.\n" );
    mods = ownedMods.concat( mods );
  }

  var gap = new Array( longestModName - 2).join( " " );
  logger.blue( "  Name" + gap + "Version     Updated              Have?       Website" );

  var fields = [
    ["name", longestModName + 2],
    ["version", 13],
    ["updated", 22],
    ["installed", 13],
    ["site", 65]
  ];
  var lenFields = fields.length;

  var depMapper = function( dep ) {
    return dep + "@" + aMod.dependencies[dep];
  };

  for ( var h = 0, lenh = mods.length; h < lenh; h++ ) {
    var aMod = mods[h];

    var headline = "  ";
    for ( var f = 0; f < lenFields; f++) {
      var field = fields[f]
        , name = field[0]
        , spacing = field[1]
        , data = aMod[name]
        , spaces = spacing - (data + "").length
        ;

      headline += data;
      if ( spaces < 1 ) {
        spaces = 2;
      }

      headline += new Array( spaces ).join( " " );
    }

    logger.green( headline );

    if ( verbose ) {
      console.log( "  Description:  " + aMod.desc );
      if ( aMod.dependencies ) {
        var asArray = Object.keys( aMod.dependencies ).map( depMapper );
        console.log( "  Dependencies: " + asArray.join( ", " ) );
      }
      console.log( "" );
    }
  }

  if ( !verbose ) {
    logger.green( "\n  To view more module details, execute 'mimosa mod:search -v' for 'verbose' logging." );
  }

  if ( !installed ) {
    logger.green( "\n  To view only the installed Mimosa modules, add the [-i/--installed] flag: 'mimosa mod:list -i'" );
  }

  logger.green( "  \n  Install modules by executing 'mimosa mod:install <<name of module>>' \n\n" );

  process.exit( 0 );
};

var list = function( opts ) {
  var exec = require( "child_process" ).exec;

  if ( opts.mdebug ) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }

  logger.green( "\n  Searching Mimosa modules...\n" );

  exec( "npm config get proxy", function( error, stdout, stderr ) {
    var options = {};
    var proxy = stdout.replace( /(\r\n|\n|\r)/gm, "" );
    if ( !error && proxy != "null" ) {
      options.proxy = proxy;
    }
    var request = require( "request" );
    request.get( "http://mimosa-data.herokuapp.com/modules", options, function( error, client, response ) {
      if ( error !== null ) {
        console.log( error );
        return;
      }
      var mods = JSON.parse( response );
      printResults( mods, opts );
    });
  });
};

var register = function( program ) {
  program
    .command( "mod:list" )
    .option( "-D, --mdebug", "run in debug mode")
    .option( "-v, --verbose", "list more details about each module")
    .option( "-i, --installed", "Show just those modules that are currently installed.")
    .description( "get list of all mimosa modules in NPM" )
    .action( list )
    .on( "--help", function() {
      var logger = require( "logmimosa" );
      logger.green( "  The mod:list command will search npm for all packages and return a list" );
      logger.green( "  of Mimosa modules that are available for install. This command will also" );
      logger.green( "  inform you if your project has out of date modules." );
      logger.blue(  "\n    $ mimosa mod:list\n" );
      logger.green( "  Pass an 'installed' flag to only see the modules you have installed." );
      logger.blue(  "\n    $ mimosa mod:list --installed\n" );
      logger.blue(  "\n    $ mimosa mod:list -i\n" );
      logger.green( "  Pass a 'verbose' flag to get additional information about each module" );
      logger.blue(  "\n    $ mimosa mod:list --verbose\n" );
      logger.blue(  "\n    $ mimosa mod:list -v\n" );
    });
};

module.exports = register;