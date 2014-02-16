"use strict";
var fs, logger, _read,
  __slice = [].slice;

fs = require('fs');

logger = require('logmimosa');

_read = function(config, options, next) {
  var done, hasFiles, i, _ref;
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
    if (file.inputFileName == null) {
      return done();
    }
    return fs.readFile(file.inputFileName, function(err, text) {
      if (err != null) {
        logger.error("Failed to read file [[ " + file.inputFileName + " ]], " + err);
      } else {
        if (options.isJavascript || options.isCSS || options.isTemplate) {
          text = text.toString();
        }
        file.inputFileText = text;
      }
      return done();
    });
  });
};

exports.registration = function(config, register) {
  var e;
  e = config.extensions;
  register(['add', 'update', 'buildFile'], 'read', _read, __slice.call(e.javascript).concat(__slice.call(e.copy)));
  return register(['add', 'update', 'remove', 'buildExtension'], 'read', _read, __slice.call(e.css).concat(__slice.call(e.template)));
};
