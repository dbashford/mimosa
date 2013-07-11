"use strict";
var IcedCompiler, JSCompiler, iced,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

iced = require('iced-coffee-script');

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

  IcedCompiler.prototype.registration = function(config, register) {
    IcedCompiler.__super__.registration.call(this, config, register);
    return this._cleanUpSourceMapsRegister(register, this.extensions, this.icedConfig);
  };

  IcedCompiler.prototype.compile = function(file, cb) {
    return this._icedAndCoffeeCompile(file, cb, this.icedConfig, iced);
  };

  return IcedCompiler;

})(JSCompiler);
