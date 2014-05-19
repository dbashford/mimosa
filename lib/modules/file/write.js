"use strict";
var _write,
  __slice = [].slice;

_write = function(config, options, next) {
  var done, fileUtils, hasFiles, i, _ref;
  fileUtils = require('../../util/file');
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
      config.log.warn("Compile of file [[ " + file.inputFileName + " ]] resulted in empty output.");
    }
    if (config.log.isDebug()) {
      config.log.debug("Writing file [[ " + file.outputFileName + " ]]");
    }
    return fileUtils.writeFile(file.outputFileName, file.outputFileText, function(err) {
      if (err != null) {
        config.log.error("Failed to write new file [[ " + file.outputFileName + " ]], Error: " + err, {
          exitIfBuild: true
        });
      } else {
        config.log.success("Wrote file [[ " + file.outputFileName + " ]]", options);
      }
      return done();
    });
  });
};

exports.registration = function(config, register) {
  var e;
  e = config.extensions;
  register(['add', 'update', 'remove', 'buildExtension'], 'write', _write, __slice.call(e.template).concat(__slice.call(e.css)));
  return register(['add', 'update', 'buildFile'], 'write', _write, __slice.call(e.javascript).concat(__slice.call(e.copy), __slice.call(e.misc)));
};
