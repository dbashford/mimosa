"use strict";
var HTMLCompiler, TemplateCompiler,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = HTMLCompiler = (function(_super) {
  __extends(HTMLCompiler, _super);

  HTMLCompiler.prototype.clientLibrary = null;

  HTMLCompiler.prototype.libName = "underscore";

  HTMLCompiler.prettyName = "HTML - Just Plain HTML Snippets, no compiling";

  HTMLCompiler.defaultExtensions = ["template"];

  function HTMLCompiler(config, extensions) {
    this.extensions = extensions;
    this.compile = __bind(this.compile, this);
    HTMLCompiler.__super__.constructor.call(this, config);
  }

  HTMLCompiler.prototype.prefix = function(config) {
    if (config.template.amdWrap) {
      return "define(function () { var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  HTMLCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return templates; });';
    } else {
      return "";
    }
  };

  HTMLCompiler.prototype.compile = function(file, cb) {
    var compiledOutput, err, error, output;
    this.compilerLib.templateSettings = {
      evaluate: /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
      interpolate: /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g
    };
    try {
      compiledOutput = this.compilerLib.template(file.inputFileText);
      output = "" + compiledOutput.source + "()";
    } catch (_error) {
      err = _error;
      error = err;
    }
    this.compilerLib.templateSettings = {
      evaluate: /<%([\s\S]+?)%>/g,
      interpolate: /<%=([\s\S]+?)%>/g
    };
    return cb(error, output);
  };

  return HTMLCompiler;

})(TemplateCompiler);
