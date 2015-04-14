var buildDestinationFile, compile, fileUtils, findBasesToCompile, findBasesToCompileStartup, fs, getAllFiles, importsForFile, logger, path, _, _baseFilesToCompileFromChangedInclude, _baseOptionsObject, _changedBaseFilesToCompile, _findExistingImportFullPath, _findImportsInFile, _isInclude, _notCompilerFile;

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

fileUtils = require('../../util/file');

_baseOptionsObject = function(config, fileName) {
  var destFile;
  destFile = buildDestinationFile(config, fileName);
  return {
    inputFileName: fileName,
    outputFileName: destFile,
    inputFileText: null,
    outputFileText: null
  };
};

_notCompilerFile = function(file, compilerExtensions) {
  var fileExtension;
  fileExtension = path.extname(file.inputFileName).replace(/\./, '');
  return compilerExtensions.indexOf(fileExtension) === -1 || fileExtension === "css";
};

_isInclude = function(fileName, includeToBaseHash, compiler) {
  if (compiler.isInclude) {
    return compiler.isInclude(fileName, includeToBaseHash);
  } else {
    return includeToBaseHash[fileName] != null;
  }
};

buildDestinationFile = function(config, fileName) {
  var baseCompDir;
  baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir);
  return baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css";
};

getAllFiles = function(config, extensions, canFullyImportCSS) {
  var files;
  files = fileUtils.readdirSyncRecursive(config.watch.sourceDir, config.watch.exclude, config.watch.excludeRegex, true).filter(function(file) {
    return extensions.some(function(ext) {
      var fileExt;
      fileExt = file.slice(-(ext.length + 1));
      return fileExt === ("." + ext) || (fileExt === ".css" && canFullyImportCSS);
    });
  });
  return files;
};

compile = function(config, options, next, extensions, compiler) {
  var done, hasFiles, i, _ref;
  hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
  if (!hasFiles) {
    return next();
  }
  i = 0;
  done = function() {
    if (++i === options.files.length) {
      return next();
    }
  };
  return options.files.forEach(function(file) {
    if (_notCompilerFile(file, extensions)) {
      return done();
    } else {
      return fs.exists(file.inputFileName, function(exists) {
        if (exists) {
          return compiler.compile(config, file, function(err, result) {
            if (err) {
              logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err, {
                exitIfBuild: true
              });
            } else {
              file.outputFileText = result;
            }
            return done();
          });
        } else {
          return done();
        }
      });
    }
  });
};

_baseFilesToCompileFromChangedInclude = function(config, includeToBaseHash) {
  var base, basePath, baseTime, bases, include, includeTime, toCompile, _i, _len;
  toCompile = [];
  for (include in includeToBaseHash) {
    bases = includeToBaseHash[include];
    for (_i = 0, _len = bases.length; _i < _len; _i++) {
      base = bases[_i];
      basePath = buildDestinationFile(config, base);
      if (fs.existsSync(basePath)) {
        includeTime = fs.statSync(include).mtime;
        baseTime = fs.statSync(basePath).mtime;
        if (includeTime > baseTime) {
          if (logger.isDebug()) {
            logger.debug("Base [[ " + base + " ]] needs compiling because [[ " + include + " ]] has been changed recently");
          }
          toCompile.push(base);
        }
      } else {
        if (logger.isDebug()) {
          logger.debug("Base file [[ " + base + " ]] hasn't been compiled yet, needs compiling");
        }
        toCompile.push(base);
      }
    }
  }
  return toCompile;
};

_changedBaseFilesToCompile = function(config, baseFiles) {
  var base, baseCompiledPath, toCompile, _i, _len;
  toCompile = [];
  for (_i = 0, _len = baseFiles.length; _i < _len; _i++) {
    base = baseFiles[_i];
    baseCompiledPath = buildDestinationFile(config, base);
    if (fs.existsSync(baseCompiledPath)) {
      if (fs.statSync(base).mtime > fs.statSync(baseCompiledPath).mtime) {
        if (logger.isDebug()) {
          logger.debug("Base file [[ " + base + " ]] needs to be compiled, it has been changed recently");
        }
        toCompile.push(base);
      }
    } else {
      if (logger.isDebug()) {
        logger.debug("Base file [[ " + base + " ]] hasn't been compiled yet, needs compiling");
      }
      toCompile.push(base);
    }
  }
  return toCompile;
};

findBasesToCompileStartup = function(config, options, next, includeToBaseHash, baseFiles) {
  var baseFilesToCompile, baseFilesToCompileNow, includeForcedBaseFiles, updatedBasedFiles;
  includeForcedBaseFiles = _baseFilesToCompileFromChangedInclude(config, includeToBaseHash);
  updatedBasedFiles = _changedBaseFilesToCompile(config, baseFiles);
  baseFilesToCompileNow = includeForcedBaseFiles.concat(updatedBasedFiles);
  baseFilesToCompile = _.uniq(baseFilesToCompileNow);
  options.files = baseFilesToCompile.map(function(base) {
    return _baseOptionsObject(config, base);
  });
  if (options.files.length > 0) {
    options.isVendor = fileUtils.isVendorCSS(config, options.files[0].inputFileName);
    options.files.forEach(function(f) {
      return f.isVendor = fileUtils.isVendorCSS(config, f.inputFileName);
    });
  }
  options.isCSS = true;
  return next();
};

_findImportsInFile = function(file, compiler) {
  var anImport, importMatches, imports, _i, _len;
  if (fs.existsSync(file)) {
    importMatches = fs.readFileSync(file, 'utf8').match(compiler.importRegex);
  }
  if (importMatches == null) {
    return [];
  }
  if (logger.isDebug()) {
    logger.debug("Imports for file [[ " + file + " ]]: " + importMatches);
  }
  imports = [];
  for (_i = 0, _len = importMatches.length; _i < _len; _i++) {
    anImport = importMatches[_i];
    compiler.importRegex.lastIndex = 0;
    anImport = compiler.importRegex.exec(anImport)[1];
    if (compiler.importSplitRegex) {
      imports.push.apply(imports, anImport.split(compiler.importSplitRegex));
    } else {
      imports.push(anImport);
    }
  }
  return imports;
};

_findExistingImportFullPath = function(fullImportFilePath, compiler, allFiles) {
  if (path.extname(fullImportFilePath) === ".css" && compiler.canFullyImportCSS) {
    return [fullImportFilePath];
  } else {
    return allFiles.filter(function(f) {
      if (path.extname(fullImportFilePath) === '') {
        f = f.replace(path.extname(f), '');
      }
      return f.slice(-fullImportFilePath.length) === fullImportFilePath;
    });
  }
};

importsForFile = function(baseFile, file, allFiles, compiler, includeToBaseHash) {
  var fullImportFilePath, fullImportFilePaths, hash, importPath, imports, includeFile, includeFiles, _i, _len, _results;
  imports = _findImportsInFile(file, compiler);
  _results = [];
  for (_i = 0, _len = imports.length; _i < _len; _i++) {
    importPath = imports[_i];
    fullImportFilePaths = compiler.getImportFilePath(file, importPath);
    if (!Array.isArray(fullImportFilePaths)) {
      fullImportFilePaths = [fullImportFilePaths];
    }
    _results.push((function() {
      var _j, _len1, _results1;
      _results1 = [];
      for (_j = 0, _len1 = fullImportFilePaths.length; _j < _len1; _j++) {
        fullImportFilePath = fullImportFilePaths[_j];
        includeFiles = _findExistingImportFullPath(fullImportFilePath, compiler, allFiles);
        _results1.push((function() {
          var _k, _len2, _results2;
          _results2 = [];
          for (_k = 0, _len2 = includeFiles.length; _k < _len2; _k++) {
            includeFile = includeFiles[_k];
            hash = includeToBaseHash[includeFile];
            if (hash != null) {
              if (logger.isDebug()) {
                logger.debug("Adding base file [[ " + baseFile + " ]] to list of base files for include [[ " + includeFile + " ]]");
              }
              if (hash.indexOf(baseFile) === -1) {
                hash.push(baseFile);
              }
            } else {
              if (fs.existsSync(includeFile)) {
                if (logger.isDebug()) {
                  logger.debug("Creating base file entry for include file [[ " + includeFile + " ]], adding base file [[ " + baseFile + " ]]");
                }
                includeToBaseHash[includeFile] = [baseFile];
              }
            }
            if (baseFile === includeFile) {
              _results2.push(logger.info("Circular import reference found in file [[ " + baseFile + " ]]"));
            } else {
              _results2.push(importsForFile(baseFile, includeFile, allFiles, compiler, includeToBaseHash));
            }
          }
          return _results2;
        })());
      }
      return _results1;
    })());
  }
  return _results;
};

findBasesToCompile = function(config, options, next, extensions, includeToBaseHash, compiler, baseFiles) {
  var base, bases, _i, _len;
  options.files = options.files.filter(function(file) {
    return _notCompilerFile(file, extensions);
  });
  if (_isInclude(options.inputFile, includeToBaseHash, compiler)) {
    if (baseFiles.indexOf(options.inputFile) > -1) {
      options.files.push(_baseOptionsObject(config, options.inputFile));
    }
    bases = includeToBaseHash[options.inputFile];
    if (bases != null) {
      if (logger.isDebug()) {
        logger.debug("Bases files for [[ " + options.inputFile + " ]]\n" + (bases.join('\n')));
      }
      for (_i = 0, _len = bases.length; _i < _len; _i++) {
        base = bases[_i];
        options.files.push(_baseOptionsObject(config, base));
      }
    }
  } else {
    if (options.lifeCycleType !== 'remove' && path.extname(options.inputFile) !== ".css") {
      options.files.push(_baseOptionsObject(config, options.inputFile));
    }
  }
  options.files = _.uniq(options.files, function(f) {
    return f.outputFileName;
  });
  return next();
};

module.exports = {
  buildDestinationFile: buildDestinationFile,
  getAllFiles: getAllFiles,
  compile: compile,
  findBasesToCompileStartup: findBasesToCompileStartup,
  importsForFile: importsForFile,
  findBasesToCompile: findBasesToCompile,
  _baseOptionsObject: _baseOptionsObject,
  _notCompilerFile: _notCompilerFile,
  _isInclude: _isInclude,
  _changedBaseFilesToCompile: _changedBaseFilesToCompile,
  _baseFilesToCompileFromChangedInclude: _baseFilesToCompileFromChangedInclude,
  _findImportsInFile: _findImportsInFile,
  _findExistingImportFullPath: _findExistingImportFullPath
};
