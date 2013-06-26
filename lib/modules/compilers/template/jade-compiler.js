"use strict";
var JadeCompiler, TemplateCompiler, jade,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

jade = require('jade');

TemplateCompiler = require('./template');

module.exports = JadeCompiler = (function(_super) {
  __extends(JadeCompiler, _super);

  JadeCompiler.prototype.clientLibrary = "jade-runtime";

  JadeCompiler.prettyName = "Jade - http://jade-lang.com/";

  JadeCompiler.defaultExtensions = ["jade"];

  function JadeCompiler(config, extensions) {
    this.extensions = extensions;
    this.compile = __bind(this.compile, this);
    JadeCompiler.__super__.constructor.call(this, config);
  }

  JadeCompiler.prototype.prefix = function(config) {
    if (config.template.amdWrap) {
      return "define(['" + (this.libraryPath()) + "'], function (jade){ var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  JadeCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return templates; });';
    } else {
      return "";
    }
  };

  JadeCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = jade.compile(file.inputFileText, {
        compileDebug: false,
        client: true,
        filename: file.inputFileName
      });
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return JadeCompiler;

})(TemplateCompiler);
