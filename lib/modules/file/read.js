"use strict";
var _read,
  __slice = [].slice;

_read = function(config, options, next) {
  var done, fs, hasFiles, i, _ref;
  fs = require('fs');
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
        config.log.error("Failed to read file [[ " + file.inputFileName + " ]], " + err, {
          exitIfBuild: true
        });
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
  register(['add', 'update', 'buildFile'], 'read', _read, __slice.call(e.javascript).concat(__slice.call(e.copy), __slice.call(e.misc)));
  return register(['add', 'update', 'remove', 'buildExtension'], 'read', _read, __slice.call(e.css).concat(__slice.call(e.template)));
};
