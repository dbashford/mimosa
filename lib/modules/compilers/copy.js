"use strict";
var CopyCompiler;

module.exports = CopyCompiler = (function() {
  function CopyCompiler(config, compiler) {
    this.compiler = compiler;
    this.extensions = this.compiler.extensions(config);
  }

  CopyCompiler.prototype.registration = function(config, register) {
    return register(['add', 'update', 'buildFile'], 'compile', this.compiler.compile, this.extensions);
  };

  return CopyCompiler;

})();
