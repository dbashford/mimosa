"use strict";
var HBSCompiler, HandlebarsCompiler, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

logger = require('logmimosa');

HandlebarsCompiler = require('./handlebars');

module.exports = HBSCompiler = (function(_super) {
  __extends(HBSCompiler, _super);

  HBSCompiler.defaultExtensions = ["hbs", "handlebars"];

  HBSCompiler.isDefault = true;

  function HBSCompiler(mimosaConfig, extensions) {
    this.mimosaConfig = mimosaConfig;
    this.extensions = extensions;
    this.compile = __bind(this.compile, this);
    HBSCompiler.__super__.constructor.call(this, this.mimosaConfig);
  }

  HBSCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    if (!this.handlebars) {
      this.determineHandlebars(this.mimosaConfig);
    }
    try {
      output = this.handlebars.precompile(file.inputFileText);
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

  return HBSCompiler;

})(HandlebarsCompiler);
