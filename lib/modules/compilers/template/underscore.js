"use strict";
var AbstractUnderscoreCompiler, TemplateCompiler,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = AbstractUnderscoreCompiler = (function(_super) {
  __extends(AbstractUnderscoreCompiler, _super);

  function AbstractUnderscoreCompiler(config) {
    this.compile = __bind(this.compile, this);    AbstractUnderscoreCompiler.__super__.constructor.call(this, config);
  }

  AbstractUnderscoreCompiler.prototype.prefix = function(config) {
    if (config.template.amdWrap) {
      return "define(['" + (this.libraryPath()) + "'], function (_) { var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  AbstractUnderscoreCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return templates; });';
    } else {
      return "";
    }
  };

  AbstractUnderscoreCompiler.prototype.compile = function(file, cb) {
    var compiledOutput, err, error, output;

    try {
      compiledOutput = this.getLibrary().template(file.inputFileText);
      output = compiledOutput.source;
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return AbstractUnderscoreCompiler;

})(TemplateCompiler);
