"use strict";
var fs, logger, _delete,
  __slice = [].slice;

fs = require('fs');

logger = require('logmimosa');

_delete = function(config, options, next) {
  var fileName;
  fileName = options.destinationFile(options.inputFile);
  return fs.exists(fileName, function(exists) {
    if (!exists) {
      if (logger.isDebug()) {
        logger.debug("File does not exist? [[ " + fileName + " ]]");
      }
      return next();
    }
    if (logger.isDebug()) {
      logger.debug("Removing file [[ " + fileName + " ]]");
    }
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

exports.registration = function(config, register) {
  var e;
  e = config.extensions;
  return register(['remove', 'cleanFile'], 'delete', _delete, __slice.call(e.javascript).concat(__slice.call(e.css), __slice.call(e.copy)));
};
