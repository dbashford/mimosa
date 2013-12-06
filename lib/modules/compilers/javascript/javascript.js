"use strict";
var JSCompiler, fileUtils, fs, logger, path, _, _cleanUpSourceMaps, _cleanUpSourceMapsRegister, _genMapFileName, _genSourceName,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

_ = require("lodash");

logger = require('logmimosa');

fileUtils = require('../../../util/file');

_genMapFileName = function(config, file) {
  var extName;
  extName = path.extname(file.inputFileName);
  return file.inputFileName.replace(extName, ".js.map").replace(config.watch.sourceDir, config.watch.compiledDir);
};

_genSourceName = function(config, file) {
  return file.inputFileName.replace(config.watch.sourceDir, config.watch.compiledDir) + ".src";
};

_cleanUpSourceMaps = function(config, options, next) {
  var done, i,
    _this = this;
  i = 0;
  done = function() {
    if (++i === 2) {
      return next();
    }
  };
  return options.files.forEach(function(file) {
    var mapFileName, sourceName;
    mapFileName = _genMapFileName(config, file);
    sourceName = _genSourceName(config, file);
    return [mapFileName, sourceName].forEach(function(f) {
      var _this = this;
      return fs.exists(f, function(exists) {
        if (exists) {
          return fs.unlink(f, function(err) {
            if (err) {
              logger.error("Error deleting file [[ " + f + " ]], " + err);
            } else {
              logger.debug("Deleted file [[ " + f + " ]]");
            }
            return done();
          });
        } else {
          return done();
        }
      });
    });
  });
};

_cleanUpSourceMapsRegister = function(register, extensions, compilerConfig) {
  if (compilerConfig.sourceMap) {
    register(['remove'], 'delete', _cleanUpSourceMaps, extensions);
  }
  return register(['cleanFile'], 'delete', _cleanUpSourceMaps, extensions);
};

exports.JSCompiler = JSCompiler = (function() {
  function JSCompiler() {
    this._compile = __bind(this._compile, this);
    this._compilerLib = __bind(this._compilerLib, this);
  }

  JSCompiler.prototype.contructor = function(config, extensions, compiler) {
    this.extensions = extensions;
    this.compiler = compiler;
    if (this.compiler.init) {
      return this.compiler.init(config, this.extensions);
    }
  };

  JSCompiler.prototype.registration = function(config, register) {
    var _ref;
    register(['buildFile'], 'init', this._compilerLib, this.extensions);
    register(['add', 'update', 'buildFile'], 'compile', this._compile, this.extensions);
    if (this.compiler.cleanUpSourceMaps) {
      return _cleanUpSourceMapsRegister(register, this.extensions, (_ref = this.compiler.config) != null ? _ref : {});
    }
  };

  JSCompiler.prototype._compilerLib = function(config, options, next) {
    if (this.delayedCompilerLib) {
      this.compiler.compilerLib = require(this.compiler.libName);
      this.delayedCompilerLib = null;
    }
    return next();
  };

  JSCompiler.prototype._compile = function(config, options, next) {
    var done, hasFiles, i, newFiles, whenDone, _ref,
      _this = this;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    i = 0;
    newFiles = [];
    whenDone = options.files.length;
    done = function() {
      if (++i === whenDone) {
        options.files = newFiles;
        return next();
      }
    };
    return options.files.forEach(function(file) {
      return _this.compile(file, function(err, output, compiledConfig, sourceMap) {
        var base64SourceMap, datauri, sourceName;
        if (err) {
          logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err, {
            exitIfBuild: true
          });
        } else {
          if (sourceMap) {
            if (compiledConfig.sourceMapDynamic) {
              sourceMap = JSON.parse(sourceMap);
              sourceMap.sources[0] = file.inputFileName;
              sourceMap.sourcesContent = [file.inputFileText];
              sourceMap.file = file.outputFileName;
              base64SourceMap = new Buffer(JSON.stringify(sourceMap)).toString('base64');
              datauri = 'data:application/json;base64,' + base64SourceMap;
              output = "" + output + "\n//@ sourceMappingURL=" + datauri + "\n";
            } else {
              whenDone += 2;
              sourceName = _genSourceName(config, file);
              fileUtils.writeFile(sourceName, file.inputFileText, function(err) {
                if (err) {
                  logger.error("Error writing source file [[ " + sourceName + " ]], " + err);
                }
                return done();
              });
              file.sourceMap = sourceMap;
              file.sourceMapName = _genMapFileName(config, file);
              fileUtils.writeFile(file.sourceMapName, sourceMap, function(err) {
                if (err) {
                  logger.error("Error writing map file [[ " + file.sourceMapName + " ]], " + err);
                }
                return done();
              });
              output = "" + output + "\n/*\n//@ sourceMappingURL=" + (path.basename(file.sourceMapName)) + "\n*/\n";
            }
          }
          file.outputFileText = output;
          newFiles.push(file);
        }
        return done();
      });
    });
  };

  return JSCompiler;

})();
