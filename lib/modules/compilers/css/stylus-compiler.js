"use strict";
var AbstractCssCompiler, StylusCompiler, fs, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

AbstractCssCompiler = require('./css');

module.exports = StylusCompiler = (function(_super) {
  __extends(StylusCompiler, _super);

  StylusCompiler.prototype.libName = 'stylus';

  StylusCompiler.prototype.importRegex = /@import ['"](.*)['"]/g;

  StylusCompiler.prettyName = "(*) Stylus - http://learnboost.github.com/stylus/";

  StylusCompiler.defaultExtensions = ["styl"];

  StylusCompiler.isDefault = true;

  function StylusCompiler(config, extensions) {
    this.extensions = extensions;
    this._determineBaseFiles = __bind(this._determineBaseFiles, this);
    this.compile = __bind(this.compile, this);
    StylusCompiler.__super__.constructor.call(this);
  }

  StylusCompiler.prototype.compile = function(file, config, options, done) {
    var cb, fileName, stylusSetup, text, _ref, _ref1, _ref2,
      _this = this;
    text = file.inputFileText;
    fileName = file.inputFileName;
    cb = function(err, css) {
      logger.debug("Finished Stylus compile for file [[ " + fileName + " ]], errors?  " + (err != null));
      _this.initBaseFilesToCompile--;
      return done(err, css);
    };
    logger.debug("Compiling Stylus file [[ " + fileName + " ]]");
    stylusSetup = this.compilerLib(text).include(path.dirname(fileName)).include(config.watch.sourceDir).set('compress', false).set('filename', fileName);
    if ((_ref = config.stylus.includes) != null) {
      _ref.forEach(function(inc) {
        return stylusSetup.include(inc);
      });
    }
    if ((_ref1 = config.stylus.resolvedUse) != null) {
      _ref1.forEach(function(ru) {
        return stylusSetup.use(ru);
      });
    }
    if ((_ref2 = config.stylus["import"]) != null) {
      _ref2.forEach(function(imp) {
        return stylusSetup["import"](imp);
      });
    }
    Object.keys(config.stylus.define).forEach(function(define) {
      return stylusSetup.define(define, config.stylus.define[define]);
    });
    return stylusSetup.render(cb);
  };

  StylusCompiler.prototype._determineBaseFiles = function() {
    var anImport, baseFiles, file, fullFilePath, fullImportPath, importPath, imported, imports, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
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
        _ref1 = this.allFiles;
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          fullFilePath = _ref1[_k];
          if (fullFilePath.indexOf(fullImportPath) === 0) {
            fullImportPath += path.extname(fullFilePath);
            break;
          }
        }
        imported.push(fullImportPath);
      }
    }
    baseFiles = _.difference(this.allFiles, imported);
    logger.debug("Base files for Stylus are:\n" + (baseFiles.join('\n')));
    return baseFiles;
  };

  StylusCompiler.prototype._getImportFilePath = function(baseFile, importPath) {
    return path.join(path.dirname(baseFile), importPath);
  };

  return StylusCompiler;

})(AbstractCssCompiler);
