"use strict";
var RactiveCompiler, TemplateCompiler,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TemplateCompiler = require('./template');

module.exports = RactiveCompiler = (function(_super) {
  __extends(RactiveCompiler, _super);

  RactiveCompiler.prototype.clientLibrary = 'ractive';

  RactiveCompiler.prototype.libName = 'ractive';

  RactiveCompiler.prettyName = "Ractive - http://www.ractivejs.org/";

  RactiveCompiler.defaultExtensions = ["rtv", "rac"];

  function RactiveCompiler(config, extensions) {
    this.extensions = extensions;
    RactiveCompiler.__super__.constructor.call(this, config);
  }

  RactiveCompiler.prototype.prefix = function(config) {
    if (config.template.wrapType === 'amd') {
      return "define(['" + (this.libraryPath()) + "'], function (){ var templates = {};\n";
    } else {
      return "var templates = {};\n";
    }
  };

  RactiveCompiler.prototype.suffix = function(config) {
    if (config.template.wrapType === 'amd') {
      return 'return templates; });';
    } else if (config.template.wrapType === "common") {
      return "module.exports = templates;";
    } else {
      return "";
    }
  };

  RactiveCompiler.prototype.compile = function(file, cb) {
    var err, error, output;
    try {
      output = this.compilerLib.parse(file.inputFileText);
      output = JSON.stringify(output);
    } catch (_error) {
      err = _error;
      error = err;
    }
    return cb(error, output);
  };

  return RactiveCompiler;

})(TemplateCompiler);
