"use strict";
var MimosaFileDeleteModule, fs, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

fs = require('fs');

logger = require('logmimosa');

MimosaFileDeleteModule = (function() {
  function MimosaFileDeleteModule() {
    this._delete = __bind(this._delete, this);
    this.registration = __bind(this.registration, this);
  }

  MimosaFileDeleteModule.prototype.registration = function(config, register) {
    var cExts, e;
    e = config.extensions;
    cExts = config.copy.extensions;
    return register(['remove', 'cleanFile'], 'delete', this._delete, __slice.call(e.javascript).concat(__slice.call(e.css), __slice.call(cExts)));
  };

  MimosaFileDeleteModule.prototype._delete = function(config, options, next) {
    var fileName;
    fileName = options.destinationFile(options.inputFile);
    return fs.exists(fileName, function(exists) {
      if (!exists) {
        logger.debug("File does not exist? [[ " + fileName + " ]]");
        return next();
      }
      logger.debug("Removing file [[ " + fileName + " ]]");
      return fs.unlink(fileName, function(err) {
        if (err) {
          logger.error("Failed to delete file [[ " + fileName + " ]]");
        } else {
          logger.success("Deleted file [[ " + fileName + " ]]", options);
        }
        return next();
      });
    });
  };

  return MimosaFileDeleteModule;

})();

module.exports = new MimosaFileDeleteModule();
