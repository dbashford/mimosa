var install = function( name, opts ) {

  var path = require( "path" )
    , fs = require( "fs" )
    , exec = require( "child_process").exec
    , wrench = require( "wrench" )
    , logger = require( "logmimosa" )
    , mimosaPath = path.join( __dirname, "..", "..", ".." )
    , mimosaPackagePath = path.join( mimosaPath, "package.json" )
    , currentDir = process.cwd()
    ;

  var _installModule = function( name, done ) {
    logger.info( "Installing module [[ " + name + " ]] into Mimosa." );
    var installString = "npm install \"" + name + "\" --save";
    exec( installString, function( err, sout, serr ) {
      if( err ) {
        logger.error( "Error installing module" );
        logger.error( err );
      } else {
        console.log( sout );
        console.log( serr );
        logger.success( "Install of [[ " + name + " ]] successful" );
      }

      if (logger.isDebug()) {
        logger.debug( "NPM INSTALL standard out\n", sout );
        logger.debug( "NPM INSTALL standard err\n", serr );
      }

      done( err );
    });
  };

  var _doNPMInstall = function( name, dirName ) {
    process.chdir( mimosaPath );
    var oldVersion = _prepareForNPMInstall( dirName );
    _installModule( name, _doneNPMInstall( dirName, oldVersion ) );
  };

  var _doneNPMInstall = function( name, oldVersion ) {
    return function( err ) {
      if ( err ) {
        _revertInstall( oldVersion, name );
      }

      var backupPath = path.join( mimosaPath, "node_modules", name + "_____backup" );
      if( fs.existsSync( backupPath ) ) {
        wrench.rmdirSyncRecursive( backupPath );
      }

      process.chdir( currentDir );
      process.exit( 0 );
    };
  };

  var _prepareForNPMInstall = function( name ) {
    var beginPath = path.join( mimosaPath, "node_modules", name );
    var oldVersion = null;
    if ( fs.existsSync( beginPath ) ) {
      var endPath = path.join( mimosaPath, "node_modules", name + "_____backup" );
      wrench.copyDirSyncRecursive( beginPath, endPath );

      // don't use require as it caches
      var mimosaPackage = JSON.parse( fs.readFileSync( mimosaPackagePath, "utf8" ) );
      oldVersion = mimosaPackage.dependencies[name];
      delete mimosaPackage.dependencies[name];
      var packageString = JSON.stringify( mimosaPackage, null, 2 );
      logger.debug( "New mimosa dependencies:\n" + packageString );
      fs.writeFileSync( mimosaPackagePath, packageString, "ascii" );
    }

    return oldVersion;
  };

  var _revertInstall = function( oldVersion, name ) {
    var backupPath = path.join( mimosaPath, "node_modules", name + "_____backup" );

    // if backup path exists, put that code back, otherwise get rid of module
    if ( fs.existsSync( backupPath ) ) {
      var endPath = path.join( mimosaPath, "node_modules", name );
      wrench.copyDirSyncRecursive( backupPath, endPath );

      // don"t use require as it caches
      var mimosaPackage = JSON.parse( fs.readFileSync( mimosaPackagePath, "utf8") );
      mimosaPackage.dependencies[name] = oldVersion;
      var packageString = JSON.stringify( mimosaPackage, null, 2 );
      logger.debug( "New mimosa dependencies:\n " + packageString );
      fs.writeFileSync( mimosaPackagePath, packageString, "ascii" );
    } else {
      var modPath = path.join( mimosaPath, "node_modules", name );
      if( fs.existsSync( modPath ) ) {
        wrench.rmdirSyncRecursive( modPath );
      }
    }
  };

  var _doLocalInstall = function() {
    _testLocalInstall(function() {
      process.chdir( mimosaPath );
      _installModule( currentDir, function() {
        process.chdir( currentDir );
        process.exit( 0 );
      });
    });
  };

  var _testLocalInstall = function( callback ) {
    logger.info( "Testing local install in place." );
    exec( "npm install", function( err, sout, serr ) {
      if ( err ) {
        return logger.error( "Could not install module locally", err );
      }

      if (logger.isDebug()) {
        logger.debug( "NPM INSTALL standard out", sout );
        logger.debug( "NPM INSTALL standard err", serr );
      }

      try {
        require( currentDir );
        logger.info( "Local install successful." );
        callback();
      } catch ( err ) {
        logger.error( "Attempted to use installed module and module failed" , err );
        console.log( err );
      }
    });
  };


  if ( opts.mdebug ) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }

  if ( name ) {
    if ( name.indexOf( "mimosa-" ) !== 0 ) {
      return logger.error( "Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server)." );
    }

    var dirName;
    if ( name.indexOf( "@" ) > 7 ) {
      dirName = name.substring( 0, name.indexOf( "@" ) );
    } else {
      dirName = name;
    }

    _doNPMInstall( name, dirName );
  } else {
    var packPath = path.join( currentDir, "package.json" )
      , pack
      ;

    try {
      pack = JSON.parse( fs.readFileSync( packPath, "utf8" ) );
    } catch ( err ) {
      return logger.error( "Unable to find package.json, or badly formatted: " , err );
    }

    if ( !pack.name && !pack.version ) {
      return logger.error( "package.json missing either name or version" );
    }

    if ( pack.name.indexOf( "mimosa-" ) !== 0 ) {
      return logger.error( "package.json name is [[ " + pack.name + " ]]. Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server)." );
    }

    _doLocalInstall();
  }
};

var register = function( program ) {
  program
    .command( "mod:install [name]" )
    .option( "-D, --mdebug", "run in debug mode" )
    .description( "install a Mimosa module into your Mimosa" )
    .action( install )
    .on( "--help", function() {
      var logger = require("logmimosa");
      logger.green("  The 'mod:install' command will install a Mimosa module into Mimosa. It does not install" );
      logger.green("  the module into your project, it just makes it available to be used by Mimosa's commands." );
      logger.green("  You can discover new modules using the 'mod:search' command.  Once you know the module you" );
      logger.green("  would like to install, put the name of the module after the 'mod:install' command." );
      logger.blue( "\n    $ mimosa mod:install mimosa-server\n" );
      logger.green("  If there is a specific version of a module you want to use, simply append '@' followed by" );
      logger.green("  the version information." );
      logger.blue( "\n    $ mimosa mod:install mimosa-server@0.1.0\n" );
      logger.green("  If you are developing a module and would like to install your local module into your local" );
      logger.green("  Mimosa, then execute 'mod:install' from the root of the module, the same location as the" );
      logger.green("  package.json, without providing a name." );
      logger.blue( "\n    $ mimosa mod:install\n" );
    });
};

module.exports = register;