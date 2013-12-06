"use strict";
var CopyCompiler, compiler;

compiler = CopyCompiler = (function() {
  function CopyCompiler(config, extensions) {
    this.extensions = extensions;
  }

  CopyCompiler.prototype.registration = function(config, register) {
    return register(['add', 'update', 'buildFile'], 'compile', this.compile, this.extensions);
  };

  CopyCompiler.prototype.compile = function(config, options, next) {
    var hasFiles, _ref;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    options.files.forEach(function(file) {
      return file.outputFileText = file.inputFileText;
    });
    return next();
  };

  return CopyCompiler;

})();

module.exports = {
  compiler: compiler,
  base: "copy",
  type: "copy"
};
