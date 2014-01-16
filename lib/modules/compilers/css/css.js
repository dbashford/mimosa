"use strict";
var CSSCompiler, fileUtils, fs, logger, path, _, __baseOptionsObject, __buildDestinationFile,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

fileUtils = require('../../../util/file');

__buildDestinationFile = function(config, fileName) {
  var baseCompDir;
  baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir);
  return baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css";
};

__baseOptionsObject = function(config, base) {
  var destFile;
  destFile = __buildDestinationFile(config, base);
  return {
    inputFileName: base,
    outputFileName: destFile,
    inputFileText: null,
    outputFileText: null
  };
};

module.exports = CSSCompiler = (function() {
  function CSSCompiler(config, extensions, compiler) {
    this.extensions = extensions;
    this.compiler = compiler;
    this.__getAllFiles = __bind(this.__getAllFiles, this);
    this._processWatchedDirectories = __bind(this._processWatchedDirectories, this);
    this._findBasesToCompileStartup = __bind(this._findBasesToCompileStartup, this);
    this.__notCompilerFile = __bind(this.__notCompilerFile, this);
    this._compile = __bind(this._compile, this);
    this._findBasesToCompile = __bind(this._findBasesToCompile, this);
    this._checkState = __bind(this._checkState, this);
    if (this.compiler.init) {
      this.compiler.init(config, this.extensions);
    }
  }

  CSSCompiler.prototype.registration = function(config, register) {
    var exts;
    register(['buildExtension'], 'init', this._processWatchedDirectories, [this.extensions[0]]);
    register(['buildExtension'], 'init', this._findBasesToCompileStartup, [this.extensions[0]]);
    register(['buildExtension'], 'compile', this._compile, [this.extensions[0]]);
    exts = this.extensions;
    if (this.compiler.canFullyImportCSS) {
      exts.push("css");
    }
    register(['add'], 'init', this._processWatchedDirectories, exts);
    register(['remove', 'cleanFile'], 'init', this._checkState, exts);
    register(['add', 'update', 'remove', 'cleanFile'], 'init', this._findBasesToCompile, exts);
    register(['add', 'update', 'remove'], 'compile', this._compile, exts);
    return register(['update', 'remove'], 'afterCompile', this._processWatchedDirectories, exts);
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
    options.files = options.files.filter(this.__notCompilerFile);
    if (this._isInclude(options.inputFile, this.includeToBaseHash)) {
      bases = this.includeToBaseHash[options.inputFile];
      if (bases != null) {
        logger.debug("Bases files for [[ " + options.inputFile + " ]]\n" + (bases.join('\n')));
        for (_i = 0, _len = bases.length; _i < _len; _i++) {
          base = bases[_i];
          options.files.push(__baseOptionsObject(config, base));
        }
      }
    } else {
      if (options.lifeCycleType !== 'remove' && path.extname(options.inputFile) !== ".css") {
        options.files.push(__baseOptionsObject(config, options.inputFile));
      }
    }
    return next();
  };

  CSSCompiler.prototype._compile = function(config, options, next) {
    var done, hasFiles, i, _ref,
      _this = this;
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
      if (_this.__notCompilerFile(file)) {
        return done();
      } else {
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
              return done();
            });
          } else {
            return done();
          }
        });
      }
    });
  };

  CSSCompiler.prototype.__notCompilerFile = function(file) {
    var ext;
    ext = path.extname(file.inputFileName).replace(/\./, '');
    return this.extensions.indexOf(ext) === -1 || ext === "css";
  };

  CSSCompiler.prototype._findBasesToCompileStartup = function(config, options, next) {
    var base, baseCompiledPath, baseFilesToCompile, baseFilesToCompileNow, basePath, baseTime, bases, include, includeTime, _i, _j, _len, _len1, _ref, _ref1;
    baseFilesToCompileNow = [];
    _ref = this.includeToBaseHash;
    for (include in _ref) {
      bases = _ref[include];
      for (_i = 0, _len = bases.length; _i < _len; _i++) {
        base = bases[_i];
        basePath = __buildDestinationFile(config, base);
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
      baseCompiledPath = __buildDestinationFile(config, base);
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
      return __baseOptionsObject(config, base);
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
    this.baseFiles = this.compiler.determineBaseFiles(allFiles).filter(function(file) {
      return path.extname(file) !== '.css';
    });
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
        var fileExt;
        fileExt = file.slice(-(ext.length + 1));
        return fileExt === ("." + ext) || (fileExt === ".css" && this.compiler.canFullyImportCSS);
      });
    });
    return files;
  };

  CSSCompiler.prototype.__importsForFile = function(baseFile, file, allFiles) {
    var anImport, fullImportFilePath, hash, importPath, imports, imports2, includeFile, includeFiles, spl, _i, _j, _len, _len1, _results,
      _this = this;
    if (fs.existsSync(file)) {
      imports = fs.readFileSync(file, 'utf8').match(this.compiler.importRegex);
    }
    if (imports == null) {
      return;
    }
    imports2 = [];
    for (_i = 0, _len = imports.length; _i < _len; _i++) {
      anImport = imports[_i];
      this.compiler.importRegex.lastIndex = 0;
      anImport = this.compiler.importRegex.exec(anImport)[1];
      console.log(anImport);
      if (this.compiler.importSplitRegex) {
        spl = anImport.split(this.compiler.importSplitRegex);
        console.log(spl);
        imports2.push.apply(imports2, spl);
      } else {
        imports2.push(anImport);
      }
    }
    imports = imports2;
    _results = [];
    for (_j = 0, _len1 = imports.length; _j < _len1; _j++) {
      importPath = imports[_j];
      fullImportFilePath = this.compiler.getImportFilePath(file, importPath);
      console.log("-------", fullImportFilePath);
      includeFiles = path.extname(fullImportFilePath) === ".css" && this.compiler.canFullyImportCSS ? [fullImportFilePath] : allFiles.filter(function(f) {
        if (!_this.compiler.partialKeepsExtension) {
          f = f.replace(path.extname(f), '');
        }
        return f.slice(-fullImportFilePath.length) === fullImportFilePath;
      });
      _results.push((function() {
        var _k, _len2, _results1;
        _results1 = [];
        for (_k = 0, _len2 = includeFiles.length; _k < _len2; _k++) {
          includeFile = includeFiles[_k];
          hash = this.includeToBaseHash[includeFile];
          if (hash != null) {
            logger.debug("Adding base file [[ " + baseFile + " ]] to list of base files for include [[ " + includeFile + " ]]");
            if (hash.indexOf(baseFile) === -1) {
              hash.push(baseFile);
            }
          } else {
            if (fs.existsSync(includeFile)) {
              logger.debug("Creating base file entry for include file [[ " + includeFile + " ]], adding base file [[ " + baseFile + " ]]");
              this.includeToBaseHash[includeFile] = [baseFile];
            }
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
