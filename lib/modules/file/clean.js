"use strict";
var MimosaCleanModule, fs, logger, path, wrench, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

wrench = require('wrench');

MimosaCleanModule = (function() {
  function MimosaCleanModule() {
    this.registration = __bind(this.registration, this);
  }

  MimosaCleanModule.prototype.registration = function(config, register) {
    return register(['postClean'], 'complete', this._clean);
  };

  MimosaCleanModule.prototype._clean = function(config, options, next) {
    var dir, directories, done, i;
    dir = config.watch.compiledDir;
    directories = wrench.readdirSyncRecursive(dir).filter(function(f) {
      return fs.statSync(path.join(dir, f)).isDirectory();
    });
    if (directories.length === 0) {
      return next();
    }
    i = 0;
    done = function() {
      if (++i === directories.length) {
        return next();
      }
    };
    return _.sortBy(directories, 'length').reverse().forEach(function(dir) {
      var dirPath, err;
      dirPath = path.join(config.watch.compiledDir, dir);
      if (fs.existsSync(dirPath)) {
        logger.debug("Deleting directory [[ " + dirPath + " ]]");
        try {
          fs.rmdirSync(dirPath);
          logger.success("Deleted empty directory [[ " + dirPath + " ]]");
        } catch (_error) {
          err = _error;
          if (err.code === 'ENOTEMPTY') {
            logger.info("Unable to delete directory [[ " + dirPath + " ]] because directory not empty");
          } else {
            logger.error("Unable to delete directory, [[ " + dirPath + " ]]");
            logger.error(err);
          }
        }
      }
      return done();
    });
  };

  return MimosaCleanModule;

})();

module.exports = new MimosaCleanModule();
