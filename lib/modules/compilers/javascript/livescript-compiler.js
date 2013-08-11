"use strict";
var JSCompiler, LiveScriptCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

JSCompiler = require("./javascript");

module.exports = LiveScriptCompiler = (function(_super) {
  __extends(LiveScriptCompiler, _super);

  LiveScriptCompiler.prototype.libName = 'LiveScript';

  LiveScriptCompiler.prettyName = "LiveScript - http://gkz.github.com/LiveScript/";

  LiveScriptCompiler.defaultExtensions = ["ls"];

  function LiveScriptCompiler(config, extensions) {
    this.extensions = extensions;
    this.options = config.livescript;
    LiveScriptCompiler.__super__.constructor.call(this);
  }

  LiveScriptCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = this.compilerLib.compile(file.inputFileText, this.options);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return LiveScriptCompiler;

})(JSCompiler);
