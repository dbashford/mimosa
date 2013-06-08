"use strict";
var AbstractUnderscoreCompiler, UnderscoreCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

AbstractUnderscoreCompiler = require('./underscore');

module.exports = UnderscoreCompiler = (function(_super) {
  __extends(UnderscoreCompiler, _super);

  UnderscoreCompiler.prototype.clientLibrary = "underscore";

  UnderscoreCompiler.prettyName = "Underscore - http://underscorejs.org/#template";

  UnderscoreCompiler.defaultExtensions = ["tpl", "underscore"];

  function UnderscoreCompiler(config, extensions) {
    this.extensions = extensions;
    UnderscoreCompiler.__super__.constructor.call(this, config);
  }

  UnderscoreCompiler.prototype.getLibrary = function() {
    return require('underscore');
  };

  return UnderscoreCompiler;

})(AbstractUnderscoreCompiler);
