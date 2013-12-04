"use strict";
var HoganCompiler, TemplateCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = HoganCompiler = (function(_super) {
  __extends(HoganCompiler, _super);

  HoganCompiler.prototype.clientLibrary = "hogan-template";

  HoganCompiler.prototype.libName = "hogan.js";

  HoganCompiler.defaultExtensions = ["hog", "hogan", "hjs"];

  function HoganCompiler(config, extensions) {
    this.extensions = extensions;
    HoganCompiler.__super__.constructor.call(this, config);
  }

  HoganCompiler.prototype.prefix = function(config) {
    if (config.template.wrapType === 'amd') {
      return "define(['" + (this.libraryPath()) + "'], function (Hogan){ var templates = {};\n";
    } else if (config.template.wrapType === "common") {
      return "var Hogan = require('" + config.template.commonLibPath + "');\nvar templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  HoganCompiler.prototype.suffix = function(config) {
    if (config.template.wrapType === 'amd') {
      return 'return templates; });';
    } else if (config.template.wrapType === "common") {
      return "\nmodule.exports = templates;";
    } else {
      return "";
    }
  };

  HoganCompiler.prototype.compile = function(file, cb) {
    var compiledOutput, err, error, output;
    try {
      compiledOutput = this.compilerLib.compile(file.inputFileText, {
        asString: true
      });
      output = "templates['" + file.templateName + "'] = new Hogan.Template(" + compiledOutput + ");\n";
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return HoganCompiler;

})(TemplateCompiler);
