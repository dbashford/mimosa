"use strict";
var HandlebarsCompiler, TemplateCompiler, fs, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

TemplateCompiler = require('./template');

module.exports = HandlebarsCompiler = (function(_super) {
  __extends(HandlebarsCompiler, _super);

  HandlebarsCompiler.prototype.clientLibrary = "handlebars";

  HandlebarsCompiler.prototype.regularBoilerplate = "if (!Handlebars) {\n  console.log(\"Handlebars library has not been passed in successfully\");\n  return;\n}\n\nif (!Object.keys) {\n   Object.keys = function (obj) {\n       var keys = [],\n           k;\n       for (k in obj) {\n           if (Object.prototype.hasOwnProperty.call(obj, k)) {\n               keys.push(k);\n           }\n       }\n       return keys;\n   };\n}\n\nvar template = Handlebars.template, templates = {};\nHandlebars.partials = templates;\n";

  HandlebarsCompiler.prototype.emberBoilerplate = "var template = Ember.Handlebars.template, templates = {};\n";

  HandlebarsCompiler.prototype.boilerplate = function() {
    if (this.ember) {
      return this.emberBoilerplate;
    } else {
      return this.regularBoilerplate;
    }
  };

  function HandlebarsCompiler(config) {
    this.prefix = __bind(this.prefix, this);
    this.boilerplate = __bind(this.boilerplate, this);
    var ec, hbs;

    HandlebarsCompiler.__super__.constructor.call(this, config);
    this.ember = config.template.handlebars.ember.enabled;
    hbs = config.template.handlebars.lib ? _.cloneDeep(config.template.handlebars.lib) : require('handlebars');
    this.handlebars = this.ember ? (this.clientLibrary = null, ec = require('./resources/ember-comp'), ec.makeHandlebars(hbs)) : hbs;
  }

  HandlebarsCompiler.prototype.prefix = function(config) {
    var defineString, defines, ext, helperDefine, helperFile, helperPath, helperPaths, jsDir, params, possibleHelperPaths, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

    if (config.template.amdWrap) {
      logger.debug("Building Handlebars template file wrapper");
      jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir);
      possibleHelperPaths = [];
      _ref = config.extensions.javascript;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ext = _ref[_i];
        _ref1 = config.template.handlebars.helpers;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          helperFile = _ref1[_j];
          possibleHelperPaths.push(path.join(jsDir, "" + helperFile + "." + ext));
        }
      }
      helperPaths = possibleHelperPaths.filter(function(p) {
        return fs.existsSync(p);
      });
      _ref2 = this.ember ? {
        defines: ["'" + config.template.handlebars.ember.path + "'"],
        params: ["Ember"]
      } : {
        defines: ["'" + (this.libraryPath()) + "'"],
        params: ["Handlebars"]
      }, defines = _ref2.defines, params = _ref2.params;
      for (_k = 0, _len2 = helperPaths.length; _k < _len2; _k++) {
        helperPath = helperPaths[_k];
        helperDefine = helperPath.replace(config.watch.sourceDir, '').replace(/\\/g, '/').replace(/^\/?\w+\/|\.\w+$/g, '');
        defines.push("'" + helperDefine + "'");
      }
      defineString = defines.join(',');
      logger.debug("Define string for Handlebars templates [[ " + defineString + " ]]");
      return "define([" + defineString + "], function (" + (params.join(',')) + "){\n  " + (this.boilerplate());
    } else {
      return this.boilerplate();
    }
  };

  HandlebarsCompiler.prototype.suffix = function(config) {
    if (config.template.amdWrap) {
      return 'return templates; });';
    } else {
      return "";
    }
  };

  HandlebarsCompiler.prototype.transformTemplate = function(text) {
    return "template(" + text + ")";
  };

  return HandlebarsCompiler;

})(TemplateCompiler);
