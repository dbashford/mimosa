"use strict";
var IcedCompiler, JSCompiler, iced, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

iced = require('iced-coffee-script');

_ = require('lodash');

JSCompiler = require("./javascript");

module.exports = IcedCompiler = (function(_super) {
  __extends(IcedCompiler, _super);

  IcedCompiler.prettyName = "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/";

  IcedCompiler.defaultExtensions = ["iced"];

  function IcedCompiler(config, extensions) {
    this.extensions = extensions;
    this.icedConfig = config.iced;
    IcedCompiler.__super__.constructor.call(this);
  }

  IcedCompiler.prototype.compile = function(file, cb) {
    var conf, err, error, output;

    try {
      conf = _.extend({}, this.icedConfig);
      output = iced.compile(file.inputFileText, conf);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return IcedCompiler;

})(JSCompiler);
