"use strict";
var EJSCompiler, TemplateCompiler,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = EJSCompiler = (function(_super) {
  __extends(EJSCompiler, _super);

  EJSCompiler.prototype.clientLibrary = "ejs-filters";

  EJSCompiler.prototype.libName = "ejs";

  EJSCompiler.prettyName = "Embedded JavaScript Templates (EJS) - https://github.com/visionmedia/ejs";

  EJSCompiler.defaultExtensions = ["ejs"];

  EJSCompiler.prototype.boilerplate = "var templates = {};\nvar globalEscape = function(html){\n  return String(html)\n    .replace(/&(?!\w+;)/g, '&amp;')\n    .replace(/</g, '&lt;')\n    .replace(/>/g, '&gt;')\n    .replace(/\"/g, '&quot;');\n};";

  function EJSCompiler(config, extensions) {
    this.extensions = extensions;
    this.transform = __bind(this.transform, this);
    this.compile = __bind(this.compile, this);
    EJSCompiler.__super__.constructor.call(this, config);
  }

  EJSCompiler.prototype.prefix = function(config) {
    if (config.template.wrapType === 'amd') {
      return "define(['" + (this.libraryPath()) + "'], function (globalFilters){\n  " + this.boilerplate;
    } else if (config.template.wrapType === "common") {
      return "var globalFilters = require('" + config.template.commonLibPath + "');\n" + this.boilerplate;
    } else {
      return this.boilerplate;
    }
  };

  EJSCompiler.prototype.suffix = function(config) {
    if (config.template.wrapType === 'amd') {
      return 'return templates; });';
    } else if (config.template.wrapType === "common") {
      return "\nmodule.exports = templates;";
    } else {
      return "";
    }
  };

  EJSCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = this.compilerLib.compile(file.inputFileText, {
        compileDebug: false,
        client: true,
        filename: file.inputFileName
      });
      output = this.transform(output + "");
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  EJSCompiler.prototype.transform = function(output) {
    return output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;');
  };

  return EJSCompiler;

})(TemplateCompiler);
