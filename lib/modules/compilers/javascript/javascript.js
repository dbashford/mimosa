"use strict";
var BaseCompiler, JSCompiler, fileUtils, fs, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

path = require('path');

fs = require('fs');

_ = require("lodash");

logger = require('logmimosa');

fileUtils = require('../../../util/file');

BaseCompiler = require('../base');

module.exports = JSCompiler = (function(_super) {
  __extends(JSCompiler, _super);

  function JSCompiler() {
    this._icedAndCoffeeCompile = __bind(this._icedAndCoffeeCompile, this);
    this._cleanUpSourceMaps = __bind(this._cleanUpSourceMaps, this);
    this._cleanUpSourceMapsRegister = __bind(this._cleanUpSourceMapsRegister, this);
    this._genSourceName = __bind(this._genSourceName, this);
    this._genMapFileName = __bind(this._genMapFileName, this);
    this._compile = __bind(this._compile, this);
    JSCompiler.__super__.constructor.call(this);
  }

  JSCompiler.prototype.registration = function(config, register) {
    return register(['add', 'update', 'buildFile'], 'compile', this._compile, this.extensions);
  };

  JSCompiler.prototype._compile = function(config, options, next) {
    var done, hasFiles, i, newFiles, whenDone, _ref,
      _this = this;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    this.determineCompilerLib(config);
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
          logger.error("File [[ " + file.inputFileName + " ]] failed compile. Reason: " + err);
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
              sourceName = _this._genSourceName(config, file);
              fileUtils.writeFile(sourceName, file.inputFileText, function(err) {
                if (err) {
                  logger.error("Error writing source file [[ " + sourceName + " ]], " + err);
                }
                return done();
              });
              file.sourceMap = sourceMap;
              file.sourceMapName = _this._genMapFileName(config, file);
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

  JSCompiler.prototype._genMapFileName = function(config, file) {
    var extName;
    extName = path.extname(file.inputFileName);
    return file.inputFileName.replace(extName, ".js.map").replace(config.watch.sourceDir, config.watch.compiledDir);
  };

  JSCompiler.prototype._genSourceName = function(config, file) {
    return file.inputFileName.replace(config.watch.sourceDir, config.watch.compiledDir) + ".src";
  };

  JSCompiler.prototype._cleanUpSourceMapsRegister = function(register, extensions, compilerConfig) {
    if (compilerConfig.sourceMap) {
      register(['remove'], 'delete', this._cleanUpSourceMaps, extensions);
    }
    return register(['cleanFile'], 'delete', this._cleanUpSourceMaps, extensions);
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

  JSCompiler.prototype._icedAndCoffeeCompile = function(file, coffeeConfig, cb) {
    var conf, err, error, output, sourceMap, _ref, _ref1, _ref2;
    conf = _.extend({}, coffeeConfig, {
      sourceFiles: [path.basename(file.inputFileName) + ".src"]
    });
    conf.literate = this.compilerLib.helpers.isLiterate(file.inputFileName);
    if (conf.sourceMap) {
      if (((_ref = conf.sourceMapExclude) != null ? _ref.indexOf(file.inputFileName) : void 0) > -1) {
        conf.sourceMap = false;
      } else if ((conf.sourceMapExcludeRegex != null) && file.inputFileName.match(conf.sourceMapExcludeRegex)) {
        conf.sourceMap = false;
      }
    }
    try {
      output = this.compilerLib.compile(file.inputFileText, conf);
      if (output.v3SourceMap) {
        sourceMap = output.v3SourceMap;
        output = output.js;
      }
    } catch (_error) {
      err = _error;
      error = "" + err + ", line " + ((_ref1 = err.location) != null ? _ref1.first_line : void 0) + ", column " + ((_ref2 = err.location) != null ? _ref2.first_column : void 0);
    }
    return cb(error, output, coffeeConfig, sourceMap);
  };

  return JSCompiler;

})(BaseCompiler);
