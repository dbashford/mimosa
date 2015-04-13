"use strict";

var path = require( "path" )
  , fs =   require( "fs" )
  , _ =      require( "lodash" )
  , logger = require( "logmimosa" )
  , fileUtils = require( "../../util/file" )
  ;

var __generateTemplateName = function( fileName, config ) {
  var nameTransform = config.template.nameTransform;
  if ( nameTransform === "fileName" ) {
    path.basename( fileName, path.extname( fileName ) );
  } else {
    // only sourceDir forward
    var filePath = fileName.replace( config.watch.sourceDir, "" );
    // normalize to unix file seps, slice off first one
    filePath = filePath.split( path.sep ).join( "/" ).substring( 1 );
    // remove ext
    filePath = filePath.replace( path.extname( filePath ), "" );
    if ( nameTransform is "filePath" ) {
      return filePath;
    } else {
      var returnFilepath;
      if ( nameTransform instanceof RegExp ) {
        returnFilepath = filePath.replace( nameTransform, "" );
      } else {
        returnFilepath = nameTransform( filePath );
      }

      if ( typeof returnFilepath !== "string" ) {
        logger.error(
          "Application of template.nameTransform for file [[ " + fileName + " ]] did not result in string",
          { exitIfBuild: true } );
        return "nameTransformFailed";
      } else {
        return returnFilepath;
      }
    }
  }
};

var __removeClientLibrary = function( clientPath, cb ) {
  if ( clientPath ) {
    fs.exists( clientPath, function( exists ) {
      if ( exists ) {
        fs.unlink( clientPath, function( err ) {
          if ( !err ) {
            logger.success( "Deleted file [[ " + clientPath + " ]]" );
          }
          cb();
        });
      } else {
        cb();
      }
    });
  } else {
    cb();
  }
};

var __testForSameTemplateName = function( files ) {
  var nameHash = {};
  for ( var i = 0, len = files.length; i < files.length; i++ ) {
    var file = files[i]
      , templateName = file.tName
      , fileName = file.fName
      ;

    if ( nameHash[templateName] ) {
      logger.error( "Files [[ " + nameHash[templateName] + " ]] and [[ " + fileName + " ]] result in templates of the same name " +
                   "being created.  You will want to change the name for one of them or they will collide." );
    } else {
      nameHash[templateName] = fileName;
    }
  }
};

var __templatePreamble = function( file ) {
  return
    "\n//\n" +
    "// Source file: [" + file.inputFileName + "]\n" +
    "// Template name: [" + file.templateName + "]\n" +
    "//\n";
};

var __destFile = function( config ) {
  return function( compilerName, folders ) {
    for (var i = 0, len = config.template.output.length; i < len; i++ ) {
      var outputConfig = config.template.output[i];
      if ( outputConfig.folders === folders ) {
        var outputFileName = outputConfig.outputFileName;
        if ( outputFileName[compilerName] ) {
          return path.join( config.watch.compiledDir, outputFileName[compilerName] + ".js" );
        } else {
          return path.join( config.watch.compiledDir, outputFileName + ".js" );
        }
      }
    }
  }
};

var _init = function( config, options, next ) {
  // if processing a file, check and see if that file
  // is inside a folder to be wrapped up in template file
  // before laying claim to that file for the template compiler
  if ( options.inputFile )
    for (var i = 0, len = config.template.output.length; i < len; i++ ) {
      var outputFileConfig = config.template.output[i];
      for (var k = 0, klen = outputFileConfig.folders.length; k < klen; k++ ) {
        var folder = outputFileConfig.folders[k];
        if ( options.inputFile.indexOf( path.join( folder, path.sep ) ) === 0 ) {
          options.isTemplateFile = true
          options.destinationFile = __destFile(config);
          return next();
        }
      }
    }
  } else {
    // if not processing a file, then processing extension
    // in which case lay claim to the extension as it
    // was specifically registered
    options.isTemplateFile = true;
    options.destinationFile = __destFile(config);
  }

  next();
};

function TemplateCompiler( config, _compiler ) {
  this.compiler = _compiler;
  this.extensions = this.compiler.extensions( config );

  if ( this.compiler.clientLibrary && ( config.template.wrapType === "amd" || config.template.writeLibrary ) ) {
    // client path is where the client library gets written
    // 1 get name of file
    this.clientPath = path.basename( this.compiler.clientLibrary );
    // 2 get pull path to output
    this.clientPath = path.join( config.vendor.javascripts, this.clientPath );
    // 3 move to compiled directory
    this.clientPath = this.clientPath.replace( config.watch.sourceDir, config.watch.compiledDir );

    // TODO when removing javascriptDir, use provided AMD path in template config
    // build relative path to library for AMD path creation
    // 1 get javascript directory
    var compiledJs = path.join( config.watch.compiledDir, config.watch.javascriptDir );
    // 2 create AMD path, remove javascript directory root, remove leading slash, then rejoin with AMD slashes
    this.libPath = this.clientPath.replace( compiledJs, "" ).substring( 1 ).split( path.sep ).join( "/" );
    // 3 remove extension
    this.libPath = this.libPath.replace( path.extname( this.libPath ), "" );
  }
}

TemplateCompiler.prototype.registration = function( config, register ) {
  this.requireRegister = config.installedModules["mimosa-require"];

  register(
    ["add", "update", "remove", "buildExtension", "buildFile"],
    "init",
    _init,
    this.extensions );

  register( ["buildExtension"], "init", this._gatherFiles, [this.extensions[0]] );
  register( ["add", "update", "remove"], "init", this._gatherFiles, this.extensions );
  register( ["buildExtension"], "compile", this._compile, [this.extensions[0]] );
  register( ["add", "update", "remove"], "compile", this._compile, this.extensions );

  register( ["cleanFile"], "init", this._removeFiles, this.extensions );

  register( ["buildExtension"], "afterCompile", this._merge, [this.extensions[0]] );
  register( ["add", "update", "remove"], "afterCompile", this._merge, this.extensions );

  if ( config.template.writeLibrary ) {
    register( ["remove"], "init", this._testForRemoveClientLibrary, this.extensions );

    register( ["add", "update"], "afterCompile", this._readInClientLibrary, this.extensions );
    register( ["buildExtension"], "afterCompile", this._readInClientLibrary, [this.extensions[0]] );
  }
};

TemplateCompiler.prototype._gatherFiles = function( config, options, next ) {
  if ( !options.isTemplateFile ) {
    return next();
  }

  options.files = [];

  // for each configured output config
  for ( var i = 0, len = config.template.output.length; i < len; i++ )
    var outputFileConfig = config.template.output[i];
    if ( options.inputFile ) {
      // if a file is involved (add, update, remove workflows),
      // need to make sure template file being processed
      for (var k = 0, klen = outputFileConfig.folders.length; k < klen; k++ ) {
        var folder = outputFileConfig.folders[k];
        // if file name begins with folder in loop, the gather files
        if ( options.inputFile.indexOf( path.join( folder, path.sep ) ) === 0 ) {
          this.__gatherFolderFilesForOutputFileConfig( config, options, outputFileConfig.folders );
          break;
        }
      }
    } else {
      // if no file is involved (build workflow), no need to look for it, just gather files
      this.__gatherFolderFilesForOutputFileConfig( config, options, outputFileConfig.folders );
    }
  }

  next(options.files.length > 0);
};

TemplateCompiler.prototype.__gatherFolderFilesForOutputFileConfig = function ( config, options, folders ) {
  for ( var i = 0, len = folders.length; i < len; i++ ) {
    var folder = folders[i];
    var folderFiles = this.__gatherFilesForFolder( config, options, folder );
    for ( var k = 0, klen = folderFiles.length; k < klen; k++ ) {
      var folderFile = folderFiles[k];
      // do not add the same file twice
      // TODO, rather than check each file add here, add them all
      // and run single _.uniq after done
      if ( _.pluck( options.files, "inputFileName" ).indexOf( folderFile.inputFileName ) === -1 ) {
        options.files.push( folderFile );
      }
    }
  }
};

TemplateCompiler.prototype.__gatherFilesForFolder = function( config, options, folder ) {
  var allFiles = fileUtils.readdirSyncRecursive(
    folder, config.watch.exclude, config.watch.excludeRegex );

  var fileNames = [];
  for( var i = 0, len = allFiles.length; i < len; i++ ) {
    var file = allFiles[i];
    var extension = path.extname( file ).substring( 1 );
    var extMatch = _.any(this.extensions, function( ex ) {
      return e === extension;
    });
    if ( extMatch ) {
      fileNames.push( file );
    }
  }

  if ( fileNames.length is 0 ) {
    return [];
  } else {
    return fileNames.map( function( file ) {
      return {
        inputFileName: file,
        inputFileText: null,
        outputFileText: null
      };
    });
  }
};

TemplateCompiler.prototype._compile = function( config, options, next ) {
  if ( !options.isTemplateFile ) {
    return next();
  }

  if ( !options.files || !options.files.length ) {
    return next();
  }

  var newFiles = [];
  for ( var i = 0, len = options.files.length; i < len; i++ ) {
    var file = options.files[i];
    file.templateName = __generateTemplateName( file.inputFileName, config );
    this.compiler.compile( config, file, function( err, result ) {
      if ( err ) {
        logger.error(
          "Template [[ " + file.inputFileName + " ]] failed to compile. Reason: " + err,
          { exitIfBuild: true } );
      } else {
        if ( !this.compiler.handlesNamespacing ) {
          result = "templates[" + file.templateName + "] = " + result + "\n";
        }
        file.outputFileText = result;
        newFiles.push( file );
      }

      if ( i === len - 1 ) {
        options.files = newFiles;
        next();
      }
    });
  }
};

TemplateCompiler.prototype._merge = function( config, options, next ) {
  if ( !options.isTemplateFile ) {
    return next();
  }

  if ( !options.files || !options.files.length ) {
    return next();
  }

  var libPath = this.__libraryPath();
  var prefix = this.compiler.prefix( config, libPath );
  var suffix = this.compiler.suffix( config );

  for ( var i = 0, len = config.template.output.length; i < len; i++ )
    var outputFileConfig = config.template.output[i];

    // if post-build, need to check to see if the outputFileConfig is valid for this compile
    if ( options.inputFile ) {
      var found = false;
      for ( var k = 0, klen = outputFileConfig.folders; k < klen; k++ ) {
        folder in
        if ( options.inputFile.indexOf( folder ) === 0 ) {
          found = true;
          break;
        }
      if ( !found ) {
        continue;
      }
    }

    var mergedText = ""
      , mergedFiles = []
      ;

    for ( var k = 0, klen = options.files.length; k < klen; k++ ) {
      var file = options.files[k];
      for ( var p = 0, plen = outputFileConfig.folders.length; p < plen; p++) {
        var folder = outputFileConfig.folders[p];
        if ( file.inputFileName && file.inputFileName.indexOf( path.join( folder, path.sep ) ) === 0 ) {
          mergedFiles.push {tName: file.templateName, fName: file.inputFileName}
          if ( !config.isOptimize ) {
            mergedText += __templatePreamble( file );
          }
          mergedText += file.outputFileText;
          break;
        }
      }
    }

    if ( mergedFiles.length > 1 ) {
      __testForSameTemplateName( mergedFiles );
    }

    if ( mergedText === "" ) {
      continue;
    }

    options.files.push({
      outputFileText: prefix + mergedText + suffix,
      outputFileName: options.destinationFile( this.compiler.name, outputFileConfig.folders ),
      isTemplate: true
    });
  }

  next();
};

TemplateCompiler.prototype._removeFiles = function( config, options, next ) {
  var totalFilesToRemove = 2;
  if ( config.template.output ) {
    totalFilesToRemove = config.template.output.length + 1;
  }

  var totalFilesRemoved = 0;
  var done = function() {
    if ( ++totalFilesRemoved === totalFilesToRemove ) {
      next();
    }
  };

  __removeClientLibrary( this.clientPath, done );
  var createDestFile = __destFile( config );

  for ( var i = 0, len = config.template.output.length; i < len; i++ ) {
    var outputFileConfig = config.template.output[i];
    var outFile = createDestFile( this.compiler.name, outputFileConfig.folders );
    __removeClientLibrary( outFile, done );
  }
};

TemplateCompiler.prototype._testForRemoveClientLibrary = function ( config, options, next ) {
  if ( !options.isTemplateFile ) {
    return next();
  }

  if ( options.files && options.files.length === 0 ) {
    logger.info( "No template files left, removing template based assets" );
    this._removeFiles( config, options, next );
  } else {
    next();
  }
};

TemplateCompiler.prototype._readInClientLibrary = function ( config, options, next ) {
  if ( !options.isTemplateFile ) {
    return next();
  }

  // do not read in client path if there isnt one, or if
  // it already exists
  if ( !this.clientPath || fs.existsSync( this.clientPath ) ) {
    return next()
  }

  fs.readFile( this.compiler.clientLibrary, "utf8", function( err, data ) {
    if ( err ) {
      logger.error( "Cannot read client library [[ " + this.compiler.clientLibrary + " ]]" );
      return next();
    }

    options.files.push({
      outputFileName: this.clientPath,
      outputFileText: data
    });

    next();
  });
};

TemplateCompiler.prototype.__libraryPath = function() {
  if ( this.requireRegister ) {
    return this.requireRegister.aliasForPath(this.libPath)
      || this.requireRegister.aliasForPath("./" + this.libPath)
      || this.libPath;
  } else {
    return this.libPath;
  }
};

module.exports = TemplateCompiler;
