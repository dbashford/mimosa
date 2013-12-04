"use strict";
var AbstractCssCompiler, LessCompiler, fs, importRegex, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

AbstractCssCompiler = require('./css');

importRegex = /@import ['"](.*)['"]/g;

/*
_compile = (file, config, options, done) =>
  fileName = file.inputFileName
  logger.debug "Compiling LESS file [[ #{fileName} ]], first parsing..."
  parser = new @compilerLib.Parser
    paths: [config.watch.sourceDir, path.dirname(fileName)],
    filename: fileName
  parser.parse file.inputFileText, (error, tree) =>
    if error?
      return done(error, null)

    try
      logger.debug "...then converting to CSS"
      result = tree.toCSS()
    catch ex
      err = "#{ex.type}Error:#{ex.message}"
      err += " in '#{ex.filename}:#{ex.line}:#{ex.column}'" if ex.filename

    if logger.isDebug
      logger.debug "Finished LESS compile for file [[ #{fileName} ]], errors? #{err?}"

    done(err, result)

_determineBaseFiles = (allFiles) =>
  imported = []
  for file in allFiles
    imports = fs.readFileSync(file, 'utf8').match(importRegex)
    continue unless imports?

    for anImport in imports
      importRegex.lastIndex = 0
      importPath = importRegex.exec(anImport)[1]
      fullImportPath = path.join path.dirname(file), importPath
      imported.push fullImportPath

  baseFiles = _.difference(allFiles, imported)
  logger.debug "Base files for LESS are:\n#{baseFiles.join('\n')}"
  baseFiles

_getImportFilePath = (baseFile, importPath) ->
  path.join path.dirname(baseFile), importPath


module.exports =
  defaultExtensions: ["less"]
  partialKeepsExtension: true
  importRegex: importRegex
  libName: 'less'
  compile: _compile
  determineBaseFiles: _determineBaseFiles
  getImportFilePath: _getImportFilePath
*/


module.exports = LessCompiler = (function(_super) {
  __extends(LessCompiler, _super);

  LessCompiler.prototype.libName = 'less';

  LessCompiler.prototype.importRegex = /@import ['"](.*)['"]/g;

  LessCompiler.prototype.partialKeepsExtension = true;

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
      if (logger.isDebug) {
        logger.debug("Finished LESS compile for file [[ " + fileName + " ]], errors? " + (err != null));
      }
      return done(err, result);
    });
  };

  LessCompiler.prototype._determineBaseFiles = function(allFiles) {
    var anImport, baseFiles, file, fullImportPath, importPath, imported, imports, _i, _j, _len, _len1;
    imported = [];
    for (_i = 0, _len = allFiles.length; _i < _len; _i++) {
      file = allFiles[_i];
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
    baseFiles = _.difference(allFiles, imported);
    logger.debug("Base files for LESS are:\n" + (baseFiles.join('\n')));
    return baseFiles;
  };

  LessCompiler.prototype._getImportFilePath = function(baseFile, importPath) {
    return path.join(path.dirname(baseFile), importPath);
  };

  return LessCompiler;

})(AbstractCssCompiler);
