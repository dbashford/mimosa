"use strict";
var EmblemCompiler, HandlebarsCompiler,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

HandlebarsCompiler = require('./handlebars');

module.exports = EmblemCompiler = (function(_super) {
  __extends(EmblemCompiler, _super);

  EmblemCompiler.prototype.libName = "emblem";

  EmblemCompiler.prettyName = "Emblem - http://emblemjs.com/";

  EmblemCompiler.defaultExtensions = ["emblem", "embl"];

  function EmblemCompiler(mimosaConfig, extensions) {
    this.mimosaConfig = mimosaConfig;
    this.extensions = extensions;
    this.compile = __bind(this.compile, this);
    EmblemCompiler.__super__.constructor.call(this, this.mimosaConfig);
  }

  EmblemCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    if (!this.handlebars) {
      this.determineHandlebars(this.mimosaConfig);
    }
    try {
      output = this.compilerLib.precompile(this.handlebars, file.inputFileText);
      output = this.transformTemplate(output.toString());
      if (this.ember) {
        output = "Ember.TEMPLATES['" + file.templateName + "'] = " + output;
      }
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return EmblemCompiler;

})(HandlebarsCompiler);
