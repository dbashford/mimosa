"use strict";
var HoganCompiler, TemplateCompiler, hogan,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

hogan = require("hogan.js");

TemplateCompiler = require('./template');

module.exports = HoganCompiler = (function(_super) {
  __extends(HoganCompiler, _super);

  HoganCompiler.prototype.clientLibrary = "hogan-template";

  HoganCompiler.prettyName = "Hogan - http://twitter.github.com/hogan.js/";

  HoganCompiler.defaultExtensions = ["hog", "hogan", "hjs"];

  function HoganCompiler(config, extensions) {
    this.extensions = extensions;
    HoganCompiler.__super__.constructor.call(this, config);
  }

  HoganCompiler.prototype.prefix = function(config) {
    if (config.template.amdWrap) {
      return "define(['" + (this.libraryPath()) + "'], function (Hogan){ var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  HoganCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return templates; });';
    } else {
      return "";
    }
  };

  HoganCompiler.prototype.compile = function(file, cb) {
    var compiledOutput, err, error, output;

    try {
      compiledOutput = hogan.compile(file.inputFileText, {
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
