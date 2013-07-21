"use strict";
var MimosaFileBeforeReadModule, fileUtils, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

logger = require('logmimosa');

fileUtils = require('../../util/file');

MimosaFileBeforeReadModule = (function() {
  function MimosaFileBeforeReadModule() {
    this._fileNeedsCompilingStartup = __bind(this._fileNeedsCompilingStartup, this);
  }

  MimosaFileBeforeReadModule.prototype.registration = function(config, register) {
    var cExts, e;
    e = config.extensions;
    cExts = config.copy.extensions;
    register(['buildFile'], 'beforeRead', this._fileNeedsCompilingStartup, __slice.call(e.javascript).concat(__slice.call(cExts)));
    return register(['add', 'update'], 'beforeRead', this._fileNeedsCompiling, __slice.call(e.javascript).concat(__slice.call(cExts)));
  };

  MimosaFileBeforeReadModule.prototype._fileNeedsCompiling = function(config, options, next) {
    var done, hasFiles, i, newFiles, _ref,
      _this = this;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    i = 0;
    newFiles = [];
    done = function() {
      if (++i === options.files.length) {
        if (newFiles.length > 0) {
          options.files = newFiles;
        }
        return next();
      }
    };
    return options.files.forEach(function(file) {
      if (options.isJavascript && config.requireRegister) {
        newFiles.push(file);
        return done();
      } else {
        return fileUtils.isFirstFileNewer(file.inputFileName, file.outputFileName, function(isNewer) {
          if (isNewer) {
            newFiles.push(file);
          }
          return done();
        });
      }
    });
  };

  MimosaFileBeforeReadModule.prototype._fileNeedsCompilingStartup = function(config, options, next) {
    if (config.requireRegister && options.isJSNotVendor) {
      logger.debug("File [[ " + options.inputFile + " ]] NEEDS compiling/copying");
      return next();
    } else {
      return this._fileNeedsCompiling(config, options, next);
    }
  };

  return MimosaFileBeforeReadModule;

})();

module.exports = new MimosaFileBeforeReadModule();
