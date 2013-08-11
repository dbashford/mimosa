"use strict";
var AbstractCssCompiler, LessCompiler, fs, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

AbstractCssCompiler = require('./css');

module.exports = LessCompiler = (function(_super) {
  __extends(LessCompiler, _super);

  LessCompiler.prototype.libName = 'less';

  LessCompiler.prototype.importRegex = /@import ['"](.*)['"]/g;

  LessCompiler.prototype.partialKeepsExtension = true;

  LessCompiler.prettyName = "LESS - http://lesscss.org/";

  LessCompiler.defaultExtensions = ["less"];

  function LessCompiler(config, extensions) {
    this.extensions = extensions;
    this._determineBaseFiles = __bind(this._determineBaseFiles, this);
    this.compile = __bind(this.compile, this);
    LessCompiler.__super__.constructor.call(this);
  }

  LessCompiler.prototype.compile = function(file, config, options, done) {
    var fileName, parser,
      _this = this;
    fileName = file.inputFileName;
    logger.debug("Compiling LESS file [[ " + fileName + " ]], first parsing...");
    parser = new this.compilerLib.Parser({
      paths: [config.watch.sourceDir, path.dirname(fileName)],
      filename: fileName
    });
    return parser.parse(file.inputFileText, function(error, tree) {
      var err, ex, result;
      _this.initBaseFilesToCompile--;
      if (error != null) {
        return done(error, null);
      }
      try {
        logger.debug("...then converting to CSS");
        result = tree.toCSS();
      } catch (_error) {
        ex = _error;
        err = "" + ex.type + "Error:" + ex.message;
        if (ex.filename) {
          err += " in '" + ex.filename + ":" + ex.line + ":" + ex.column + "'";
        }
      }
      logger.debug("Finished LESS compile for file [[ " + fileName + " ]], errors? " + (err != null));
      return done(err, result);
    });
  };

  LessCompiler.prototype._determineBaseFiles = function() {
    var anImport, baseFiles, file, fullImportPath, importPath, imported, imports, _i, _j, _len, _len1, _ref;
    imported = [];
    _ref = this.allFiles;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      file = _ref[_i];
      imports = fs.readFileSync(file, 'utf8').match(this.importRegex);
      if (imports == null) {
        continue;
      }
      for (_j = 0, _len1 = imports.length; _j < _len1; _j++) {
        anImport = imports[_j];
        this.importRegex.lastIndex = 0;
        importPath = this.importRegex.exec(anImport)[1];
        fullImportPath = path.join(path.dirname(file), importPath);
        imported.push(fullImportPath);
      }
    }
    baseFiles = _.difference(this.allFiles, imported);
    logger.debug("Base files for LESS are:\n" + (baseFiles.join('\n')));
    return baseFiles;
  };

  LessCompiler.prototype._getImportFilePath = function(baseFile, importPath) {
    return path.join(path.dirname(baseFile), importPath);
  };

  return LessCompiler;

})(AbstractCssCompiler);
