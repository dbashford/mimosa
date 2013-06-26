"use strict";
var CoffeeCompiler, JSCompiler, coffee, path, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

path = require("path");

_ = require("lodash");

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
    if (this.coffeeConfig.sourceMap) {
      register(['remove'], 'delete', this._cleanUpSourceMaps, this.extensions);
    }
    return register(['cleanFile'], 'delete', this._cleanUpSourceMaps, this.extensions);
  };

  CoffeeCompiler.prototype.compile = function(file, cb) {
    var conf, err, error, output, sourceMap, _ref, _ref1, _ref2;
    conf = _.extend({}, this.coffeeConfig, {
      sourceFiles: [path.basename(file.inputFileName) + ".src"]
    });
    conf.literate = coffee.helpers.isLiterate(file.inputFileName);
    if (conf.sourceMap) {
      if (((_ref = conf.sourceMapExclude) != null ? _ref.indexOf(file.inputFileName) : void 0) > -1) {
        conf.sourceMap = false;
      } else if ((conf.sourceMapExcludeRegex != null) && file.inputFileName.match(conf.sourceMapExcludeRegex)) {
        conf.sourceMap = false;
      }
    }
    try {
      output = coffee.compile(file.inputFileText, conf);
      if (output.v3SourceMap) {
        sourceMap = output.v3SourceMap;
        output = output.js;
      }
    } catch (_error) {
      err = _error;
      error = "" + err + ", line " + ((_ref1 = err.location) != null ? _ref1.first_line : void 0) + ", column " + ((_ref2 = err.location) != null ? _ref2.first_column : void 0);
    }
    return cb(error, output, sourceMap);
  };

  return CoffeeCompiler;

})(JSCompiler);
