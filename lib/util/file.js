var path = require( "path" )
  , fs = require( "fs" )
  , logger = require( "logmimosa" )
  ;

exports.removeDotMimosa = function() {
  var dotMimosaDir = path.join( process.cwd(), ".mimosa" );
  if ( fs.existsSync( dotMimosaDir ) ) {
    var wrench = require( "wrench" );
    wrench.rmdirSyncRecursive( dotMimosaDir );
  }
};

exports.isCSS = isCSS = function( fileName ) {
  return path.extname( fileName ) === ".css";
};

exports.isJavascript = isJavascript = function ( fileName ) {
  return path.extname( fileName ) === ".js";
};

exports.isVendorCSS = isVendorCSS = function( config, fileName ) {
  return fileName.indexOf( config.vendor.stylesheets ) === 0;
};

exports.isVendorJS = isVendorJS = function( config, fileName ) {
  return fileName.indexOf( config.vendor.javascripts ) === 0;
};

exports.mkdirRecursive = mkdirRecursive = function( p, made ) {
  if ( !made ) {
    made = null;
  }

  p = path.resolve( p );

  try {
    fs.mkdirSync( p );
    made = made || p;
  } catch ( err ) {
    if ( err.code === "ENOENT" ) {
      made = mkdirRecursive( path.dirname( p ), made );
      mkdirRecursive( p, made );
    } else if ( err.code === "EEXIST" ) {
      try {
        stat = fs.statSync( p );
      } catch ( err2 ) {
        throw err;
      }
      if ( !stat.isDirectory() ) {
        throw err;
      }
    } else {
      throw err;
    }
  }
  return made;
};

exports.writeFile = function( fileName, content, callback ) {
  var dirname = path.dirname( fileName );
  if ( !fs.existsSync( dirname ) ) {
    mkdirRecursive( dirname );
  }

  fs.writeFile( fileName, content, "utf8", function( err ) {
    var error = null;
    if ( err ) {
      error = "Failed to write file: " + fileName + ", " + err;
    }
    callback( error, fileName );
  });
};

exports.isFirstFileNewer = function( file1, file2, cb ) {
  if ( !file1 ) {
    return cb( false );
  }

  if ( !file2 ) {
    return cb( true );
  }

  fs.exists( file1, function ( exists1 ) {
    if ( !exists1 ) {
      logger.warn( "Detected change with file [[ " + file1 + " ]] but is no longer present." );
      return cb( false );
    }

    fs.exists( file2, function ( exists2 ) {
      if ( !exists2 ) {
        // logger.debug( "File missing, so is new file [[ " + file2 + " ]]" );
        return cb( true );
      }

      fs.stat( file2, function( err, stats2 ) {
        fs.stat( file1, function( err, stats1 ) {
          if ( !( stats1 && stats2 ) ) {
            // logger.debug( "Somehow a file went missing [[ " + stats1 + " ]], [[ " + stats2 + " ]] " );
            return cb( false );
          }

          if ( stats1.mtime > stats2.mtime ) {
            cb( true );
          } else {
            cb( false );
          }
        });
      });
    });
  });
};

exports.readdirSyncRecursive = function( baseDir, excludes, excludeRegex, ignoreDirectories ) {
  if ( !excludes ) {
    excludes = [];
  }

  if ( ignoreDirectories !== true ) {
    ignoreDirectories = false;
  }

  baseDir = baseDir.replace( /\/$/, "" );

  var readdirSyncRecursive = function( baseDir ) {
    var curFiles = fs.readdirSync( baseDir ).map( function ( fname ) {
      return path.join( baseDir, fname );
    });

    if ( excludes.length ) {
      curFiles = curFiles.filter( function ( fname ) {
        for( var i = 0; i < excludes.length ; i++ ) {
          var exclude = excludes[i];
          if ( fname === exclude || fname.indexOf( exclude ) === 0 ) {
            return false;
          }
        }
        return true;
      });
    }

    if ( excludeRegex ) {
      curFiles = curFiles.filter( function( fname ) {
        return !fname.match( excludeRegex );
      });
    }

    var nextDirs = curFiles.filter( function( fname ) {
      return fs.statSync( fname ).isDirectory();
    });

    while ( nextDirs.length ) {
      curFiles = curFiles.concat( readdirSyncRecursive( nextDirs.shift() ) );
    }
    return curFiles;
  };

  var allFiles = readdirSyncRecursive( baseDir );
  if ( ignoreDirectories ) {
    allFiles = allFiles.filter( function( fname ) {
      return fs.statSync( fname ).isFile();
    });
  }

  return allFiles;
};