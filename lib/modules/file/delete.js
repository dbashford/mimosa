"use strict";
var _delete,
  __slice = [].slice;

_delete = function(config, options, next) {
  var fileName, fs;
  fs = require('fs');
  if (!options.destinationFile) {
    return next();
  }
  fileName = options.destinationFile(options.inputFile);
  return fs.exists(fileName, function(exists) {
    if (!exists) {
      if (config.log.isDebug()) {
        config.log.debug("File does not exist? [[ " + fileName + " ]]");
      }
      return next();
    }
    if (config.log.isDebug()) {
      config.log.debug("Removing file [[ " + fileName + " ]]");
    }
    return fs.unlink(fileName, function(err) {
      if (err) {
        config.log.error("Failed to delete file [[ " + fileName + " ]]");
      } else {
        config.log.success("Deleted file [[ " + fileName + " ]]", options);
      }
      return next();
    });
  });
};

exports.registration = function(config, register) {
  var e;
  e = config.extensions;
  return register(['remove', 'cleanFile'], 'delete', _delete, __slice.call(e.javascript).concat(__slice.call(e.css), __slice.call(e.copy), __slice.call(e.misc)));
};
