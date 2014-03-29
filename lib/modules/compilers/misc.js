"use strict";
var MiscCompiler;

module.exports = MiscCompiler = (function() {
  function MiscCompiler(config, compiler) {
    this.compiler = compiler;
    this.extensions = this.compiler.extensions(config);
  }

  MiscCompiler.prototype.registration = function(config, register) {
    return register(['add', 'update', 'buildFile'], 'compile', this.compiler.compile, this.extensions);
  };

  return MiscCompiler;

})();
