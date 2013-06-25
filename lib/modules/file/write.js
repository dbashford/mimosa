"use strict";
var MimosaFileWriteModule, fileUtils, fs, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

fs = require('fs');

logger = require('logmimosa');

fileUtils = require('../../util/file');

MimosaFileWriteModule = (function() {
  function MimosaFileWriteModule() {
    this._write = __bind(this._write, this);
  }

  MimosaFileWriteModule.prototype.registration = function(config, register) {
    var cExts, e;

    e = config.extensions;
    cExts = config.copy.extensions;
    register(['add', 'update', 'remove', 'buildExtension'], 'write', this._write, __slice.call(e.template).concat(__slice.call(e.css)));
    return register(['add', 'update', 'buildFile'], 'write', this._write, __slice.call(e.javascript).concat(__slice.call(cExts)));
  };

  MimosaFileWriteModule.prototype._write = function(config, options, next) {
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
      if ((file.outputFileText !== "" && !file.outputFileText) || !file.outputFileName) {
        return done();
      }
      if (file.outputFileText === "") {
        logger.warn("Compile of file [[ " + file.inputFileName + " ]] resulted in empty output.");
      }
      logger.debug("Writing file [[ " + file.outputFileName + " ]]");
      return fileUtils.writeFile(file.outputFileName, file.outputFileText, function(err) {
        if (err != null) {
          logger.error("Failed to write new file [[ " + file.outputFileName + " ]], Error: " + err);
        } else {
          logger.success("Compiled/copied [[ " + file.outputFileName + " ]]", options);
        }
        return done();
      });
    });
  };

  return MimosaFileWriteModule;

})();

module.exports = new MimosaFileWriteModule();
