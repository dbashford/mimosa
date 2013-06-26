"use strict";
var CocoCompiler, JSCompiler, coco, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

coco = require('coco');

_ = require('lodash');

JSCompiler = require("./javascript");

module.exports = CocoCompiler = (function(_super) {
  __extends(CocoCompiler, _super);

  CocoCompiler.prettyName = "Coco - https://github.com/satyr/coco";

  CocoCompiler.defaultExtensions = ["co", "coco"];

  function CocoCompiler(config, extensions) {
    this.extensions = extensions;
    this.config = config.coco;
    CocoCompiler.__super__.constructor.call(this);
  }

  CocoCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = coco.compile(file.inputFileText, _.extend({}, this.config));
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return CocoCompiler;

})(JSCompiler);
