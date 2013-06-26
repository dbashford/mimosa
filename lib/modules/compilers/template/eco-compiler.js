"use strict";
var EcoCompiler, TemplateCompiler, eco,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

eco = require("eco");

TemplateCompiler = require('./template');

module.exports = EcoCompiler = (function(_super) {
  __extends(EcoCompiler, _super);

  EcoCompiler.prototype.clientLibrary = null;

  EcoCompiler.prettyName = "Embedded CoffeeScript Templates (ECO) - https://github.com/sstephenson/eco";

  EcoCompiler.defaultExtensions = ["eco"];

  function EcoCompiler(config, extensions) {
    this.extensions = extensions;
    EcoCompiler.__super__.constructor.call(this, config);
  }

  EcoCompiler.prototype.prefix = function(config) {
    if (config.template.amdWrap) {
      return "define(function (){ var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  EcoCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return templates; });';
    } else {
      return "";
    }
  };

  EcoCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = eco.precompile(file.inputFileText);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return EcoCompiler;

})(TemplateCompiler);
