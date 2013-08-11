"use strict";
var DustCompiler, TemplateCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = DustCompiler = (function(_super) {
  __extends(DustCompiler, _super);

  DustCompiler.prototype.clientLibrary = "dust";

  DustCompiler.prototype.handlesNamespacing = true;

  DustCompiler.prototype.libName = "dustjs-linkedin";

  DustCompiler.prettyName = "(*) Dust - https://github.com/linkedin/dustjs/";

  DustCompiler.defaultExtensions = ["dust"];

  function DustCompiler(config, extensions) {
    this.extensions = extensions;
    DustCompiler.__super__.constructor.call(this, config);
  }

  DustCompiler.prototype.prefix = function(config) {
    if (config.template.amdWrap) {
      return "define(['" + (this.libraryPath()) + "'], function (dust){ ";
    } else {
      return "";
    }
  };

  DustCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return dust; });';
    } else {
      return "";
    }
  };

  DustCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = this.compilerLib.compile(file.inputFileText, file.templateName);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return DustCompiler;

})(TemplateCompiler);
