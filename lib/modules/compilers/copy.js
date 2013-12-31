"use strict";
var CopyCompiler, compiler, logger, _compile;

logger = require('logmimosa');

_compile = function(config, options, next) {
  var hasFiles, _ref;
  hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
  if (!hasFiles) {
    return next();
  }
  options.files.forEach(function(file) {
    var _ref1;
    if ((((_ref1 = config.copy) != null ? _ref1.excludeRegex : void 0) != null) && file.inputFileName.match(config.copy.excludeRegex)) {
      return logger.debug("skipping copy file [[ " + file.inputFileName + " ]], file is excluded via regex");
    } else if (config.copy.exclude.indexOf(file.inputFileName) > -1) {
      return logger.debug("skipping copy file [[ " + file.inputFileName + " ]], file is excluded via string path");
    } else {
      return file.outputFileText = file.inputFileText;
    }
  });
  return next();
};

compiler = CopyCompiler = (function() {
  function CopyCompiler(config, extensions) {
    this.extensions = extensions;
  }

  CopyCompiler.prototype.registration = function(config, register) {
    return register(['add', 'update', 'buildFile'], 'compile', _compile, this.extensions);
  };

  return CopyCompiler;

})();

module.exports = {
  compiler: compiler,
  name: "copy",
  compilerType: "copy"
};
