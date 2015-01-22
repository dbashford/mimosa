"use strict";
var JSCompiler, fileUtils, fs, logger, path, _cleanUpSourceMaps, _cleanUpSourceMapsRegister, _genMapFileName, _genSourceName,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

logger = require('logmimosa');

fileUtils = require('../../util/file');

_genMapFileName = function(config, file) {
  var extName;
  extName = path.extname(file.inputFileName);
  return file.inputFileName.replace(extName, ".js.map").replace(config.watch.sourceDir, config.watch.compiledDir);
};

_genSourceName = function(config, file) {
  return file.inputFileName.replace(config.watch.sourceDir, config.watch.compiledDir) + ".src";
};

_cleanUpSourceMaps = function(config, options, next) {
  var done, i;
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
      return fs.exists(f, function(exists) {
        if (exists) {
          return fs.unlink(f, function(err) {
            if (err) {
              logger.error("Error deleting file [[ " + f + " ]], " + err);
            } else {
              if (logger.isDebug()) {
                logger.debug("Deleted file [[ " + f + " ]]");
              }
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

_cleanUpSourceMapsRegister = function(register, extensions) {
  register(['remove'], 'delete', _cleanUpSourceMaps, extensions);
  return register(['cleanFile'], 'delete', _cleanUpSourceMaps, extensions);
};

module.exports = JSCompiler = (function() {
  function JSCompiler(config, compiler) {
    this.compiler = compiler;
    this._compile = __bind(this._compile, this);
  }

  JSCompiler.prototype.registration = function(config, register) {
    var exts;
    exts = this.compiler.extensions(config);
    register(['add', 'update', 'remove', 'cleanFile', 'buildFile'], 'init', this._determineOutputFile, exts);
    register(['add', 'update', 'buildFile'], 'compile', this._compile, exts);
    if (this.compiler.cleanUpSourceMaps) {
      return _cleanUpSourceMapsRegister(register, exts);
    }
  };

  JSCompiler.prototype._determineOutputFile = function(config, options, next) {
    if (options.files && options.files.length) {
      options.destinationFile = function(fileName) {
        var baseCompDir;
        baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir);
        return baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js";
      };
      options.files.forEach(function(file) {
        return file.outputFileName = options.destinationFile(file.inputFileName);
      });
    }
    return next();
  };

  JSCompiler.prototype._compile = function(config, options, next) {
    var done, i, newFiles, whenDone, _ref,
      _this = this;
    if (!((_ref = options.files) != null ? _ref.length : void 0)) {
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
      if (logger.isDebug()) {
        logger.debug("Calling compiler function for compiler [[ " + _this.compiler.name + " ]]");
      }
      file.isVendor = options.isVendor;
      return _this.compiler.compile(config, file, function(err, output, compilerConfig, sourceMap) {
        var base64SourceMap, datauri, sourceName;
        if (err) {
          logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err, {
            exitIfBuild: true
          });
        } else {
          if (sourceMap) {
            if (compilerConfig.sourceMapDynamic) {
              sourceMap = JSON.parse(sourceMap);
              sourceMap.sources[0] = file.inputFileName;
              sourceMap.sourcesContent = [file.inputFileText];
              sourceMap.file = file.outputFileName;
              base64SourceMap = new Buffer(JSON.stringify(sourceMap)).toString('base64');
              datauri = 'data:application/json;base64,' + base64SourceMap;
              if (compilerConfig.sourceMapConditional) {
                output = "" + output + "\n//@ sourceMappingURL=" + datauri + "\n";
              } else {
                output = "" + output + "\n//# sourceMappingURL=" + datauri + "\n";
              }
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
              if (compilerConfig.sourceMapConditional) {
                output = "" + output + "\n//@ sourceMappingURL=" + (path.basename(file.sourceMapName)) + "\n";
              } else {
                output = "" + output + "\n//# sourceMappingURL=" + (path.basename(file.sourceMapName)) + "\n";
              }
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
