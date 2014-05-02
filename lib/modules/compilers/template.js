"use strict";
var TemplateCompiler, fileUtils, fs, logger, path, _, __destFile, __generateTemplateName, __removeClientLibrary, __templatePreamble, __testForSameTemplateName, _init,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

_ = require('lodash');

logger = require('logmimosa');

fileUtils = require('../../util/file');

__generateTemplateName = function(fileName, config) {
  var filePath, nameTransform, returnFilepath;
  nameTransform = config.template.nameTransform;
  if (nameTransform === "fileName") {
    return path.basename(fileName, path.extname(fileName));
  } else {
    filePath = fileName.replace(config.watch.sourceDir, '');
    filePath = filePath.split(path.sep).join('/').substring(1);
    filePath = filePath.replace(path.extname(filePath), '');
    if (nameTransform === "filePath") {
      return filePath;
    } else {
      returnFilepath = nameTransform instanceof RegExp ? filePath.replace(nameTransform, '') : nameTransform(filePath);
      if (typeof returnFilepath !== "string") {
        logger.error("Application of template.nameTransform for file [[ " + fileName + " ]] did not result in string", {
          exitIfBuild: true
        });
        return "nameTransformFailed";
      } else {
        return returnFilepath;
      }
    }
  }
};

__removeClientLibrary = function(clientPath, cb) {
  if (clientPath != null) {
    return fs.exists(clientPath, function(exists) {
      if (exists) {
        if (logger.isDebug()) {
          logger.debug("Removing client library [[ " + clientPath + " ]]");
        }
        return fs.unlink(clientPath, function(err) {
          if (!err) {
            logger.success("Deleted file [[ " + clientPath + " ]]");
          }
          return cb();
        });
      } else {
        return cb();
      }
    });
  } else {
    return cb();
  }
};

__testForSameTemplateName = function(files) {
  var nameHash;
  nameHash = {};
  return files.forEach(function(file) {
    var fileName, templateName;
    templateName = file.tName;
    fileName = file.fName;
    if (nameHash[templateName]) {
      return logger.error(("Files [[ " + nameHash[templateName] + " ]] and [[ " + fileName + " ]] result in templates of the same name ") + "being created.  You will want to change the name for one of them or they will collide.");
    } else {
      return nameHash[templateName] = fileName;
    }
  });
};

__templatePreamble = function(file) {
  return "\n//\n// Source file: [" + file.inputFileName + "]\n// Template name: [" + file.templateName + "]\n//\n";
};

__destFile = function(config) {
  return function(compilerName, folders) {
    var outputConfig, outputFileName, _i, _len, _ref;
    _ref = config.template.output;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      outputConfig = _ref[_i];
      if (outputConfig.folders === folders) {
        outputFileName = outputConfig.outputFileName;
        if (outputFileName[compilerName]) {
          return path.join(config.watch.compiledDir, outputFileName[compilerName] + ".js");
        } else {
          return path.join(config.watch.compiledDir, outputFileName + ".js");
        }
      }
    }
  };
};

_init = function(config, options, next) {
  var folder, outputFileConfig, _i, _j, _len, _len1, _ref, _ref1;
  if (options.inputFile) {
    _ref = config.template.output;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      outputFileConfig = _ref[_i];
      _ref1 = outputFileConfig.folders;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        folder = _ref1[_j];
        if (options.inputFile.indexOf(path.join(folder, path.sep)) === 0) {
          options.isTemplateFile = true;
          options.destinationFile = __destFile(config);
          return next();
        }
      }
    }
  } else {
    options.isTemplateFile = true;
    options.destinationFile = __destFile(config);
  }
  return next();
};

module.exports = TemplateCompiler = (function() {
  function TemplateCompiler(config, compiler) {
    var compiledJs;
    this.compiler = compiler;
    this.__libraryPath = __bind(this.__libraryPath, this);
    this._readInClientLibrary = __bind(this._readInClientLibrary, this);
    this._testForRemoveClientLibrary = __bind(this._testForRemoveClientLibrary, this);
    this._removeFiles = __bind(this._removeFiles, this);
    this._merge = __bind(this._merge, this);
    this._compile = __bind(this._compile, this);
    this.__gatherFilesForFolder = __bind(this.__gatherFilesForFolder, this);
    this.__gatherFolderFilesForOutputFileConfig = __bind(this.__gatherFolderFilesForOutputFileConfig, this);
    this._gatherFiles = __bind(this._gatherFiles, this);
    this.extensions = this.compiler.extensions(config);
    if (this.compiler.clientLibrary && (config.template.wrapType === 'amd' || config.template.writeLibrary)) {
      this.clientPath = path.basename(this.compiler.clientLibrary);
      this.clientPath = path.join(config.vendor.javascripts, this.clientPath);
      this.clientPath = this.clientPath.replace(config.watch.sourceDir, config.watch.compiledDir);
      compiledJs = path.join(config.watch.compiledDir, config.watch.javascriptDir);
      this.libPath = this.clientPath.replace(compiledJs, '').substring(1).split(path.sep).join('/');
      this.libPath = this.libPath.replace(path.extname(this.libPath), '');
    }
  }

  TemplateCompiler.prototype.registration = function(config, register) {
    this.requireRegister = config.installedModules['mimosa-require'];
    register(['add', 'update', 'remove', 'buildExtension', 'buildFile'], 'init', _init, this.extensions);
    register(['buildExtension'], 'init', this._gatherFiles, [this.extensions[0]]);
    register(['add', 'update', 'remove'], 'init', this._gatherFiles, this.extensions);
    register(['buildExtension'], 'compile', this._compile, [this.extensions[0]]);
    register(['add', 'update', 'remove'], 'compile', this._compile, this.extensions);
    register(['cleanFile'], 'init', this._removeFiles, this.extensions);
    register(['buildExtension'], 'afterCompile', this._merge, [this.extensions[0]]);
    register(['add', 'update', 'remove'], 'afterCompile', this._merge, this.extensions);
    if (config.template.writeLibrary) {
      register(['remove'], 'init', this._testForRemoveClientLibrary, this.extensions);
      register(['add', 'update'], 'afterCompile', this._readInClientLibrary, this.extensions);
      return register(['buildExtension'], 'afterCompile', this._readInClientLibrary, [this.extensions[0]]);
    }
  };

  TemplateCompiler.prototype._gatherFiles = function(config, options, next) {
    var folder, outputFileConfig, _i, _j, _len, _len1, _ref, _ref1;
    if (!options.isTemplateFile) {
      return next();
    }
    options.files = [];
    _ref = config.template.output;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      outputFileConfig = _ref[_i];
      if (options.inputFile != null) {
        _ref1 = outputFileConfig.folders;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          folder = _ref1[_j];
          if (options.inputFile.indexOf(path.join(folder, path.sep)) === 0) {
            this.__gatherFolderFilesForOutputFileConfig(config, options, outputFileConfig.folders);
            break;
          }
        }
      } else {
        this.__gatherFolderFilesForOutputFileConfig(config, options, outputFileConfig.folders);
      }
    }
    return next(options.files.length > 0);
  };

  TemplateCompiler.prototype.__gatherFolderFilesForOutputFileConfig = function(config, options, folders) {
    var folder, folderFile, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = folders.length; _i < _len; _i++) {
      folder = folders[_i];
      _results.push((function() {
        var _j, _len1, _ref, _results1;
        _ref = this.__gatherFilesForFolder(config, options, folder);
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          folderFile = _ref[_j];
          if (_.pluck(options.files, 'inputFileName').indexOf(folderFile.inputFileName) === -1) {
            _results1.push(options.files.push(folderFile));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  TemplateCompiler.prototype.__gatherFilesForFolder = function(config, options, folder) {
    var allFiles, extension, file, fileNames, _i, _len;
    allFiles = fileUtils.readdirSyncRecursive(folder, config.watch.exclude, config.watch.excludeRegex);
    fileNames = [];
    for (_i = 0, _len = allFiles.length; _i < _len; _i++) {
      file = allFiles[_i];
      extension = path.extname(file).substring(1);
      if (_.any(this.extensions, function(e) {
        return e === extension;
      })) {
        fileNames.push(file);
      }
    }
    if (fileNames.length === 0) {
      return [];
    } else {
      return fileNames.map(function(file) {
        return {
          inputFileName: file,
          inputFileText: null,
          outputFileText: null
        };
      });
    }
  };

  TemplateCompiler.prototype._compile = function(config, options, next) {
    var newFiles, _ref,
      _this = this;
    if (!options.isTemplateFile) {
      return next();
    }
    if (!((_ref = options.files) != null ? _ref.length : void 0)) {
      return next();
    }
    newFiles = [];
    return options.files.forEach(function(file, i) {
      if (logger.isDebug()) {
        logger.debug("Compiling template [[ " + file.inputFileName + " ]]");
      }
      file.templateName = __generateTemplateName(file.inputFileName, config);
      return _this.compiler.compile(config, file, function(err, result) {
        if (err) {
          logger.error("Template [[ " + file.inputFileName + " ]] failed to compile. Reason: " + err, {
            exitIfBuild: true
          });
        } else {
          if (!_this.compiler.handlesNamespacing) {
            result = "templates['" + file.templateName + "'] = " + result + "\n";
          }
          file.outputFileText = result;
          newFiles.push(file);
        }
        if (i === options.files.length - 1) {
          options.files = newFiles;
          return next();
        }
      });
    });
  };

  TemplateCompiler.prototype._merge = function(config, options, next) {
    var folder, found, libPath, mergedFiles, mergedText, outputFileConfig, prefix, suffix, _i, _j, _len, _len1, _ref, _ref1, _ref2,
      _this = this;
    if (!options.isTemplateFile) {
      return next();
    }
    if (!((_ref = options.files) != null ? _ref.length : void 0)) {
      return next();
    }
    libPath = this.__libraryPath();
    prefix = this.compiler.prefix(config, libPath);
    suffix = this.compiler.suffix(config);
    _ref1 = config.template.output;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      outputFileConfig = _ref1[_i];
      if (options.inputFile) {
        found = false;
        _ref2 = outputFileConfig.folders;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          folder = _ref2[_j];
          if (options.inputFile.indexOf(folder) === 0) {
            found = true;
            break;
          }
        }
        if (!found) {
          continue;
        }
      }
      mergedText = "";
      mergedFiles = [];
      options.files.forEach(function(file) {
        var _k, _len2, _ref3, _ref4, _results;
        _ref3 = outputFileConfig.folders;
        _results = [];
        for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
          folder = _ref3[_k];
          if (((_ref4 = file.inputFileName) != null ? _ref4.indexOf(path.join(folder, path.sep)) : void 0) === 0) {
            mergedFiles.push({
              tName: file.templateName,
              fName: file.inputFileName
            });
            if (!config.isOptimize) {
              mergedText += __templatePreamble(file);
            }
            mergedText += file.outputFileText;
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      if (mergedFiles.length > 1) {
        __testForSameTemplateName(mergedFiles);
      }
      if (mergedText === "") {
        continue;
      }
      options.files.push({
        outputFileText: prefix + mergedText + suffix,
        outputFileName: options.destinationFile(this.compiler.name, outputFileConfig.folders),
        isTemplate: true
      });
    }
    return next();
  };

  TemplateCompiler.prototype._removeFiles = function(config, options, next) {
    var createDestFile, done, i, outFile, outputFileConfig, total, _i, _len, _ref, _results;
    total = config.template.output ? config.template.output.length + 1 : 2;
    i = 0;
    done = function() {
      if (++i === total) {
        return next();
      }
    };
    __removeClientLibrary(this.clientPath, done);
    createDestFile = __destFile(config);
    _ref = config.template.output;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      outputFileConfig = _ref[_i];
      outFile = createDestFile(this.compiler.name, outputFileConfig.folders);
      _results.push(__removeClientLibrary(outFile, done));
    }
    return _results;
  };

  TemplateCompiler.prototype._testForRemoveClientLibrary = function(config, options, next) {
    var _ref;
    if (!options.isTemplateFile) {
      return next();
    }
    if (((_ref = options.files) != null ? _ref.length : void 0) === 0) {
      logger.info("No template files left, removing template based assets");
      return this._removeFiles(config, options, next);
    } else {
      return next();
    }
  };

  TemplateCompiler.prototype._readInClientLibrary = function(config, options, next) {
    var _this = this;
    if (!options.isTemplateFile) {
      return next();
    }
    if ((this.clientPath == null) || fs.existsSync(this.clientPath)) {
      logger.debug("Not going to write template client library");
      return next();
    }
    if (logger.isDebug()) {
      logger.debug("Adding template client library [[ " + this.compiler.clientLibrary + " ]] to list of files to write");
    }
    return fs.readFile(this.compiler.clientLibrary, "utf8", function(err, data) {
      if (err) {
        logger.error("Cannot read client library [[ " + _this.compiler.clientLibrary + " ]]");
        return next();
      }
      options.files.push({
        outputFileName: _this.clientPath,
        outputFileText: data
      });
      return next();
    });
  };

  TemplateCompiler.prototype.__libraryPath = function() {
    var _ref, _ref1;
    if (this.requireRegister) {
      return (_ref = (_ref1 = this.requireRegister.aliasForPath(this.libPath)) != null ? _ref1 : this.requireRegister.aliasForPath("./" + this.libPath)) != null ? _ref : this.libPath;
    } else {
      return this.libPath;
    }
  };

  return TemplateCompiler;

})();
