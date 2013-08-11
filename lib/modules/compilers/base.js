var BaseCompiler, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

logger = require('logmimosa');

module.exports = BaseCompiler = (function() {
  function BaseCompiler() {
    this.determineCompilerLib = __bind(this.determineCompilerLib, this);
  }

  BaseCompiler.prototype.determineCompilerLib = function(mimosaConfig) {
    if (!this.compilerLib && this.libName) {
      if (mimosaConfig.compilers.libs[this.constructor.base]) {
        logger.debug("Using provided [[ " + this.constructor.base + " ]] compiler");
        return this.compilerLib = mimosaConfig.compilers.libs[this.constructor.base];
      } else {
        logger.debug("Using Mimosa embedded [[ " + this.constructor.base + " ]] compiler");
        if (this.libName !== 'node-sass') {
          return this.compilerLib = require(this.libName);
        }
      }
    }
  };

  return BaseCompiler;

})();
