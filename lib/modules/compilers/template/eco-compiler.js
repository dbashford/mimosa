"use strict";
var EcoCompiler, TemplateCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = EcoCompiler = (function(_super) {
  __extends(EcoCompiler, _super);

  EcoCompiler.prototype.clientLibrary = null;

  EcoCompiler.prototype.libName = 'eco';

  EcoCompiler.defaultExtensions = ["eco"];

  function EcoCompiler(config, extensions) {
    this.extensions = extensions;
    EcoCompiler.__super__.constructor.call(this, config);
  }

  EcoCompiler.prototype.prefix = function(config) {
    if (config.template.wrapType === 'amd') {
      return "define(function (){ var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  EcoCompiler.prototype.suffix = function(config) {
    if (config.template.wrapType === 'amd') {
      return 'return templates; });';
    } else if (config.template.wrapType === "common") {
      return "\nmodule.exports = templates;";
    } else {
      return "";
    }
  };

  EcoCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = this.compilerLib.precompile(file.inputFileText);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return EcoCompiler;

})(TemplateCompiler);
