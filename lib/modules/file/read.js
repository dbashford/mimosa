"use strict";
var MimosaFileReadModule, fs, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

fs = require('fs');

logger = require('logmimosa');

MimosaFileReadModule = (function() {
  function MimosaFileReadModule() {
    this.registration = __bind(this.registration, this);
  }

  MimosaFileReadModule.prototype.registration = function(config, register) {
    var cExts, e;
    e = config.extensions;
    cExts = config.copy.extensions;
    register(['add', 'update', 'buildFile'], 'read', this._read, __slice.call(e.javascript).concat(__slice.call(cExts)));
    return register(['add', 'update', 'remove', 'buildExtension'], 'read', this._read, __slice.call(e.css).concat(__slice.call(e.template)));
  };

  MimosaFileReadModule.prototype._read = function(config, options, next) {
    var done, hasFiles, i, _ref,
      _this = this;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    i = 0;
    done = function() {
      if (++i === options.files.length) {
        return next();
      }
    };
    return options.files.forEach(function(file) {
      var _this = this;
      if (file.inputFileName == null) {
        return done();
      }
      return fs.readFile(file.inputFileName, function(err, text) {
        if (err != null) {
          logger.error("Failed to read file [[ " + file.inputFileName + " ]], " + err);
        } else {
          if (options.isJavascript || options.isCSS || options.isTemplate) {
            text = text.toString();
          }
          file.inputFileText = text;
        }
        return done();
      });
    });
  };

  return MimosaFileReadModule;

})();

module.exports = new MimosaFileReadModule();
