"use strict";
var allExtensions, path, _fileNeedsCompiling, _fileNeedsCompilingStartup, _notValidExtension,
  __slice = [].slice;

path = require('path');

allExtensions = null;

_notValidExtension = function(file) {
  var ext;
  ext = path.extname(file.inputFileName).replace(/\./, '');
  return allExtensions.indexOf(ext) === -1;
};

_fileNeedsCompiling = function(config, options, next) {
  var done, hasFiles, i, newFiles, _ref;
  hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
  if (!hasFiles) {
    return next();
  }
  i = 0;
  newFiles = [];
  done = function() {
    if (++i === options.files.length) {
      options.files = newFiles;
      return next();
    }
  };
  return options.files.forEach(function(file) {
    var fileUtils;
    if ((options.isJavascript && config.__forceJavaScriptRecompile) || _notValidExtension(file)) {
      newFiles.push(file);
      return done();
    } else {
      fileUtils = require('../../util/file');
      return fileUtils.isFirstFileNewer(file.inputFileName, file.outputFileName, function(isNewer) {
        if (isNewer) {
          newFiles.push(file);
        } else {
          if (config.log.isDebug()) {
            config.log.debug("Not processing [[ " + file.inputFileName + " ]] as it is not newer than destination file.");
          }
        }
        return done();
      });
    }
  });
};

_fileNeedsCompilingStartup = function(config, options, next) {
  if (config.__forceJavaScriptRecompile && options.isJSNotVendor) {
    if (config.log.isDebug()) {
      config.log.debug("File [[ " + options.inputFile + " ]] NEEDS compiling/copying");
    }
    return next();
  } else {
    return _fileNeedsCompiling(config, options, next);
  }
};

exports.registration = function(config, register) {
  allExtensions = __slice.call(config.extensions.javascript).concat(__slice.call(config.extensions.copy));
  register(['buildFile'], 'beforeRead', _fileNeedsCompilingStartup, allExtensions);
  return register(['add', 'update'], 'beforeRead', _fileNeedsCompiling, allExtensions);
};
