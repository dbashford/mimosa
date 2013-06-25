"use strict";
var JSCompiler, fileUtils, fs, logger, path,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

fileUtils = require('../../../util/file');

logger = require('logmimosa');

module.exports = JSCompiler = (function() {
  function JSCompiler() {
    this._cleanUpSourceMaps = __bind(this._cleanUpSourceMaps, this);
    this._genSourceName = __bind(this._genSourceName, this);
    this._genMapFileName = __bind(this._genMapFileName, this);
    this._compile = __bind(this._compile, this);
  }

  JSCompiler.prototype.registration = function(config, register) {
    return register(['add', 'update', 'buildFile'], 'compile', this._compile, this.extensions);
  };

  JSCompiler.prototype._compile = function(config, options, next) {
    var done, i, newFiles, whenDone,
      _this = this;

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
      return _this.compile(file, function(err, output, sourceMap) {
        var sourceName;

        if (err) {
          logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err);
        } else {
          if (sourceMap) {
            whenDone += 2;
            file.sourceMap = sourceMap;
            file.sourceMapName = _this._genMapFileName(config, file);
            fileUtils.writeFile(file.sourceMapName, sourceMap, function(err) {
              if (err) {
                logger.error("Error writing map file [[ " + file.sourceMapName + " ]], " + err);
              }
              return done();
            });
            sourceName = _this._genSourceName(config, file);
            fileUtils.writeFile(sourceName, file.inputFileText, function(err) {
              if (err) {
                logger.error("Error writing source file [[ " + sourceName + " ]], " + err);
              }
              return done();
            });
            output = "" + output + "\n/*\n//@ sourceMappingURL=" + (path.basename(file.sourceMapName)) + "\n*/\n";
          }
          file.outputFileText = output;
          newFiles.push(file);
        }
        return done();
      });
    });
  };

  JSCompiler.prototype._genMapFileName = function(config, file) {
    var extName;

    extName = path.extname(file.inputFileName);
    return file.inputFileName.replace(extName, ".js.map").replace(config.watch.sourceDir, config.watch.compiledDir);
  };

  JSCompiler.prototype._genSourceName = function(config, file) {
    return file.inputFileName.replace(config.watch.sourceDir, config.watch.compiledDir) + ".src";
  };

  JSCompiler.prototype._cleanUpSourceMaps = function(config, options, next) {
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

      mapFileName = _this._genMapFileName(config, file);
      sourceName = _this._genSourceName(config, file);
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

  return JSCompiler;

})();
