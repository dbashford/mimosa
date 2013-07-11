"use strict";
var CoffeeCompiler, JSCompiler, coffee,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

coffee = require('coffee-script');

JSCompiler = require("./javascript");

module.exports = CoffeeCompiler = (function(_super) {
  __extends(CoffeeCompiler, _super);

  CoffeeCompiler.prettyName = "(*) CoffeeScript - http://coffeescript.org/";

  CoffeeCompiler.defaultExtensions = ["coffee", "litcoffee"];

  CoffeeCompiler.isDefault = true;

  function CoffeeCompiler(config, extensions) {
    this.extensions = extensions;
    this.coffeeConfig = config.coffeescript;
    CoffeeCompiler.__super__.constructor.call(this);
  }

  CoffeeCompiler.prototype.registration = function(config, register) {
    CoffeeCompiler.__super__.registration.call(this, config, register);
    return this._cleanUpSourceMapsRegister(register, this.extensions, this.coffeeConfig);
  };

  CoffeeCompiler.prototype.compile = function(file, cb) {
    return this._icedAndCoffeeCompile(file, cb, this.coffeeConfig, coffee);
  };

  return CoffeeCompiler;

})(JSCompiler);
