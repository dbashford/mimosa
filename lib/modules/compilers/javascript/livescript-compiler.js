"use strict";
var JSCompiler, LiveScriptCompiler, liveScript,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

liveScript = require('LiveScript');

JSCompiler = require("./javascript");

module.exports = LiveScriptCompiler = (function(_super) {
  __extends(LiveScriptCompiler, _super);

  LiveScriptCompiler.prettyName = "LiveScript - http://gkz.github.com/LiveScript/";

  LiveScriptCompiler.defaultExtensions = ["ls"];

  function LiveScriptCompiler(config, extensions) {
    this.extensions = extensions;
    LiveScriptCompiler.__super__.constructor.call(this);
  }

  LiveScriptCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = liveScript.compile(file.inputFileText);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return LiveScriptCompiler;

})(JSCompiler);
