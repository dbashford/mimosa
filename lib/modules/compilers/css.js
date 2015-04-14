"use strict";
var CSSCompiler, logger, path, utils, _, _init,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

utils = require('./css-utils');

_init = function(config, options, next) {
  options.destinationFile = function(fileName) {
    return utils.buildDestinationFile(config, fileName);
  };
  return next();
};

module.exports = CSSCompiler = (function() {
  function CSSCompiler(config, compiler) {
    this.compiler = compiler;
    this._processWatchedDirectories = __bind(this._processWatchedDirectories, this);
    this._checkState = __bind(this._checkState, this);
    this._findBasesToCompile = __bind(this._findBasesToCompile, this);
    this._findBasesToCompileStartup = __bind(this._findBasesToCompileStartup, this);
    this._compile = __bind(this._compile, this);
    this.extensions = this.compiler.extensions(config);
  }

  CSSCompiler.prototype.registration = function(config, register) {
    var exts;
    register(['add', 'update', 'remove', 'cleanFile', 'buildExtension'], 'init', _init, this.extensions);
    register(['buildExtension'], 'init', this._processWatchedDirectories, [this.extensions[0]]);
    register(['buildExtension'], 'init', this._findBasesToCompileStartup, [this.extensions[0]]);
    register(['buildExtension'], 'compile', this._compile, [this.extensions[0]]);
    exts = this.extensions;
    if (this.compiler.canFullyImportCSS) {
      exts.push("css");
    }
    register(['add'], 'init', this._processWatchedDirectories, exts);
    register(['remove', 'cleanFile'], 'init', this._checkState, exts);
    register(['add', 'update', 'remove', 'cleanFile'], 'init', this._findBasesToCompile, exts);
    register(['add', 'update', 'remove'], 'compile', this._compile, exts);
    return register(['update', 'remove'], 'afterCompile', this._processWatchedDirectories, exts);
  };

  CSSCompiler.prototype._compile = function(config, options, next) {
    return utils.compile(config, options, next, this.extensions, this.compiler);
  };

  CSSCompiler.prototype._findBasesToCompileStartup = function(config, options, next) {
    return utils.findBasesToCompileStartup(config, options, next, this.includeToBaseHash, this.baseFiles);
  };

  CSSCompiler.prototype._findBasesToCompile = function(config, options, next) {
    return utils.findBasesToCompile(config, options, next, this.extensions, this.includeToBaseHash, this.compiler, this.baseFiles);
  };

  CSSCompiler.prototype._checkState = function(config, options, next) {
    if (this.includeToBaseHash != null) {
      return next();
    } else {
      return this._processWatchedDirectories(config, options, next);
    }
  };

  CSSCompiler.prototype._processWatchedDirectories = function(config, options, next) {
    var allBaseFiles, allFiles, baseFile, oldBaseFiles, _i, _j, _len, _len1, _ref, _ref1;
    this.includeToBaseHash = {};
    allFiles = utils.getAllFiles(config, this.extensions, this.compiler.canFullyImportCSS);
    oldBaseFiles = this.baseFiles != null ? this.baseFiles : this.baseFiles = [];
    this.baseFiles = this.compiler.determineBaseFiles(allFiles).filter(function(file) {
      return path.extname(file) !== '.css';
    });
    allBaseFiles = _.union(oldBaseFiles, this.baseFiles);
    if ((allBaseFiles.length !== oldBaseFiles.length || allBaseFiles.length !== this.baseFiles.length) && oldBaseFiles.length > 0) {
      logger.info("The list of CSS files that Mimosa will compile has changed. Mimosa will now compile the following root files to CSS:");
      _ref = this.baseFiles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        baseFile = _ref[_i];
        logger.info(baseFile);
      }
    }
    _ref1 = this.baseFiles;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      baseFile = _ref1[_j];
      utils.importsForFile(baseFile, baseFile, allFiles, this.compiler, this.includeToBaseHash);
    }
    return next();
  };

  return CSSCompiler;

})();
