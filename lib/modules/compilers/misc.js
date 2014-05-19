"use strict";
var MiscCompiler, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

logger = require('logmimosa');

module.exports = MiscCompiler = (function() {
  function MiscCompiler(config, compiler) {
    this.compiler = compiler;
    this._determineOutputFile = __bind(this._determineOutputFile, this);
    this.extensions = this.compiler.extensions(config);
  }

  MiscCompiler.prototype.registration = function(config, register) {
    register(['add', 'update', 'remove', 'cleanFile', 'buildFile'], 'init', this._determineOutputFile, this.extensions);
    return register(['add', 'update', 'buildFile'], 'compile', this.compiler.compile, this.extensions);
  };

  MiscCompiler.prototype._determineOutputFile = function(config, options, next) {
    if (options.files && options.files.length && !options.destinationFile) {
      if (this.compiler.compilerType === "copy") {
        options.destinationFile = function(fileName) {
          return fileName.replace(config.watch.sourceDir, config.watch.compiledDir);
        };
        options.files.forEach(function(file) {
          return file.outputFileName = options.destinationFile(file.inputFileName);
        });
      } else {
        if (this.compiler.determineOutputFile) {
          this.compiler.determineOutputFile(config, options);
        } else {
          if (logger.isDebug()) {
            logger.debug("compiler [[ " + this.compiler.name + " ]] does not have determineOutputFile function.");
          }
        }
      }
    }
    return next();
  };

  return MiscCompiler;

})();
