"use strict";
var AbstractUnderscoreCompiler, LodashCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

AbstractUnderscoreCompiler = require('./underscore');

module.exports = LodashCompiler = (function(_super) {
  __extends(LodashCompiler, _super);

  LodashCompiler.prototype.clientLibrary = "lodash";

  LodashCompiler.prettyName = "LoDash - http://lodash.com/docs#template";

  LodashCompiler.defaultExtensions = ["tmpl", "lodash"];

  function LodashCompiler(config, extensions) {
    this.extensions = extensions;
    LodashCompiler.__super__.constructor.call(this, config);
  }

  LodashCompiler.prototype.getLibrary = function() {
    return require('lodash');
  };

  return LodashCompiler;

})(AbstractUnderscoreCompiler);
