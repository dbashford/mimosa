"use strict";
var CSSCompiler, fileUtils, fs, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

fileUtils = require('../../../util/file');

module.exports = CSSCompiler = (function() {
  function CSSCompiler(config, extensions, compiler) {
    this.extensions = extensions;
    this.compiler = compiler;
    this.__getAllFiles = __bind(this.__getAllFiles, this);
    this._processWatchedDirectories = __bind(this._processWatchedDirectories, this);
    this._findBasesToCompileStartup = __bind(this._findBasesToCompileStartup, this);
    this._compile = __bind(this._compile, this);
    this._findBasesToCompile = __bind(this._findBasesToCompile, this);
    this._checkState = __bind(this._checkState, this);
    if (this.compiler.init) {
      this.compiler.init(config, this.extensions);
    }
  }

  CSSCompiler.prototype.registration = function(config, register) {
    register(['buildExtension'], 'init', this._processWatchedDirectories, [this.extensions[0]]);
    register(['buildExtension'], 'init', this._findBasesToCompileStartup, [this.extensions[0]]);
    register(['buildExtension'], 'compile', this._compile, [this.extensions[0]]);
    register(['add'], 'init', this._processWatchedDirectories, this.extensions);
    register(['remove', 'cleanFile'], 'init', this._checkState, this.extensions);
    register(['add', 'update', 'remove', 'cleanFile'], 'init', this._findBasesToCompile, this.extensions);
    register(['add', 'update', 'remove'], 'compile', this._compile, this.extensions);
    return register(['update', 'remove'], 'afterCompile', this._processWatchedDirectories, this.extensions);
  };

  CSSCompiler.prototype._checkState = function(config, options, next) {
    if (this.includeToBaseHash != null) {
      return next();
    } else {
      return this._processWatchedDirectories(config, options, function() {
        return next();
      });
    }
  };

  CSSCompiler.prototype._findBasesToCompile = function(config, options, next) {
    var base, bases, _i, _len;
    options.files = [];
    if (this._isInclude(options.inputFile, this.includeToBaseHash)) {
      bases = this.includeToBaseHash[options.inputFile];
      if (bases != null) {
        logger.debug("Bases files for [[ " + options.inputFile + " ]]\n" + (bases.join('\n')));
        for (_i = 0, _len = bases.length; _i < _len; _i++) {
          base = bases[_i];
          options.files.push(this.__baseOptionsObject(base, options));
        }
      } else {
        if (options.lifeCycleType !== 'remove') {
          logger.warn("Orphaned partial file: [[ " + options.inputFile + " ]]");
        }
      }
    } else {
      if (options.lifeCycleType !== 'remove') {
        options.files.push(this.__baseOptionsObject(options.inputFile, options));
      }
    }
    return next();
  };

  CSSCompiler.prototype.__baseOptionsObject = function(base, options) {
    var destFile;
    destFile = options.destinationFile(base);
    return {
      inputFileName: base,
      outputFileName: destFile,
      inputFileText: null,
      outputFileText: null
    };
  };

  CSSCompiler.prototype._compile = function(config, options, next) {
    var done, hasFiles, i, newFiles, _ref,
      _this = this;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    i = 0;
    newFiles = [];
    done = function(file) {
      if (file) {
        newFiles.push(file);
      }
      if (++i === options.files.length) {
        options.files = newFiles;
        return next();
      }
    };
    return options.files.forEach(function(file) {
      return fs.exists(file.inputFileName, function(exists) {
        if (exists) {
          return _this.compiler.compile(file, config, options, function(err, result) {
            if (err) {
              logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err, {
                exitIfBuild: true
              });
            } else {
              file.outputFileText = result;
            }
            return done(file);
          });
        } else {
          return done(file);
        }
      });
    });
  };

  CSSCompiler.prototype._findBasesToCompileStartup = function(config, options, next) {
    var base, baseCompiledPath, baseFilesToCompile, baseFilesToCompileNow, basePath, baseTime, bases, include, includeTime, _i, _j, _len, _len1, _ref, _ref1,
      _this = this;
    baseFilesToCompileNow = [];
    _ref = this.includeToBaseHash;
    for (include in _ref) {
      bases = _ref[include];
      for (_i = 0, _len = bases.length; _i < _len; _i++) {
        base = bases[_i];
        basePath = options.destinationFile(base);
        if (fs.existsSync(basePath)) {
          includeTime = fs.statSync(include).mtime;
          baseTime = fs.statSync(basePath).mtime;
          if (includeTime > baseTime) {
            logger.debug("Base [[ " + base + " ]] needs compiling because [[ " + include + " ]] has been changed recently");
            baseFilesToCompileNow.push(base);
          }
        } else {
          logger.debug("Base file [[ " + base + " ]] hasn't been compiled yet, needs compiling");
          baseFilesToCompileNow.push(base);
        }
      }
    }
    _ref1 = this.baseFiles;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      base = _ref1[_j];
      baseCompiledPath = options.destinationFile(base);
      if (fs.existsSync(baseCompiledPath)) {
        if (fs.statSync(base).mtime > fs.statSync(baseCompiledPath).mtime) {
          logger.debug("Base file [[ " + base + " ]] needs to be compiled, it has been changed recently");
          baseFilesToCompileNow.push(base);
        }
      } else {
        logger.debug("Base file [[ " + base + " ]] hasn't been compiled yet, needs compiling");
        baseFilesToCompileNow.push(base);
      }
    }
    baseFilesToCompile = _.uniq(baseFilesToCompileNow);
    options.files = baseFilesToCompile.map(function(base) {
      return _this.__baseOptionsObject(base, options);
    });
    if (options.files.length > 0) {
      options.isVendor = fileUtils.isVendorCSS(config, options.files[0].inputFileName);
    }
    options.isCSS = true;
    return next();
  };

  CSSCompiler.prototype._processWatchedDirectories = function(config, options, next) {
    var allBaseFiles, allFiles, baseFile, oldBaseFiles, _i, _j, _len, _len1, _ref, _ref1;
    this.includeToBaseHash = {};
    allFiles = this.__getAllFiles(config);
    oldBaseFiles = this.baseFiles != null ? this.baseFiles : this.baseFiles = [];
    this.baseFiles = this.compiler.determineBaseFiles(allFiles);
    allBaseFiles = _.union(oldBaseFiles, this.baseFiles);
    if ((allBaseFiles.length !== oldBaseFiles.length || allBaseFiles.length !== this.baseFiles.length) && oldBaseFiles.length > 0) {
      logger.info("The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:");
      _ref = this.baseFiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        baseFile = _ref[_i];
        logger.info(baseFile);
      }
    }
    _ref1 = this.baseFiles;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      baseFile = _ref1[_j];
      this.__importsForFile(baseFile, baseFile, allFiles);
    }
    return next();
  };

  CSSCompiler.prototype._isInclude = function(fileName, includeToBaseHash) {
    if (this.compiler.isInclude) {
      return this.compiler.isInclude(fileName, includeToBaseHash);
    } else {
      return includeToBaseHash[fileName] != null;
    }
  };

  CSSCompiler.prototype.__getAllFiles = function(config) {
    var files,
      _this = this;
    files = fileUtils.readdirSyncRecursive(config.watch.sourceDir, config.watch.exclude, config.watch.excludeRegex).filter(function(file) {
      return _this.extensions.some(function(ext) {
        return file.slice(-(ext.length + 1)) === ("." + ext);
      });
    });
    return files;
  };

  CSSCompiler.prototype.__importsForFile = function(baseFile, file, allFiles) {
    var anImport, fullImportFilePath, hash, importPath, imports, includeFile, includeFiles, _i, _len, _results,
      _this = this;
    imports = fs.readFileSync(file, 'utf8').match(this.compiler.importRegex);
    if (imports == null) {
      return;
    }
    logger.debug("Imports for file [[ " + file + " ]]: " + imports);
    _results = [];
    for (_i = 0, _len = imports.length; _i < _len; _i++) {
      anImport = imports[_i];
      this.compiler.importRegex.lastIndex = 0;
      importPath = this.compiler.importRegex.exec(anImport)[1];
      fullImportFilePath = this.compiler.getImportFilePath(file, importPath);
      includeFiles = allFiles.filter(function(f) {
        if (!_this.compiler.partialKeepsExtension) {
          f = f.replace(path.extname(f), '');
        }
        return f.slice(-fullImportFilePath.length) === fullImportFilePath;
      });
      _results.push((function() {
        var _j, _len1, _results1;
        _results1 = [];
        for (_j = 0, _len1 = includeFiles.length; _j < _len1; _j++) {
          includeFile = includeFiles[_j];
          hash = this.includeToBaseHash[includeFile];
          if (hash != null) {
            logger.debug("Adding base file [[ " + baseFile + " ]] to list of base files for include [[ " + includeFile + " ]]");
            if (hash.indexOf(baseFile) === -1) {
              hash.push(baseFile);
            }
          } else {
            logger.debug("Creating base file entry for include file [[ " + includeFile + " ]], adding base file [[ " + baseFile + " ]]");
            this.includeToBaseHash[includeFile] = [baseFile];
          }
          _results1.push(this.__importsForFile(baseFile, includeFile, allFiles));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  return CSSCompiler;

})();
