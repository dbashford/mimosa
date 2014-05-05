"use strict";
var _clean;

_clean = function(config, options, next) {
  var dir, directories, done, fs, i, path, wrench, _;
  fs = require('fs');
  path = require('path');
  _ = require('lodash');
  wrench = require('wrench');
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
      if (config.log.isDebug()) {
        config.log.debug("Deleting directory [[ " + dirPath + " ]]");
      }
      try {
        fs.rmdirSync(dirPath);
        config.log.success("Deleted empty directory [[ " + dirPath + " ]]");
      } catch (_error) {
        err = _error;
        if (err.code === 'ENOTEMPTY') {
          config.log.info("Unable to delete directory [[ " + dirPath + " ]] because directory not empty");
        } else {
          config.log.error("Unable to delete directory, [[ " + dirPath + " ]]");
          config.log.error(err);
        }
      }
    }
    return done();
  });
};

exports.registration = function(config, register) {
  return register(['postClean'], 'complete', _clean);
};
