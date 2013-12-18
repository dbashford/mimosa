"use strict";
var compile, compilerLib, determineBaseFiles, fs, getImportFilePath, importRegex, libName, logger, path, setCompilerLib, _;

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

importRegex = /@import\s+(?:(?:\(less\)|\(css\))\s+?)?['"](.*)['"]/g;

libName = "less";

compilerLib = null;

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

compile = function(file, config, options, done) {
  var fileName, parser;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  fileName = file.inputFileName;
  logger.debug("Compiling LESS file [[ " + fileName + " ]], first parsing...");
  parser = new compilerLib.Parser({
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

determineBaseFiles = function(allFiles) {
  var anImport, baseFiles, file, fullImportPath, importPath, imported, imports, _i, _j, _len, _len1;
  imported = [];
  for (_i = 0, _len = allFiles.length; _i < _len; _i++) {
    file = allFiles[_i];
    imports = fs.readFileSync(file, 'utf8').match(importRegex);
    if (imports == null) {
      continue;
    }
    for (_j = 0, _len1 = imports.length; _j < _len1; _j++) {
      anImport = imports[_j];
      importRegex.lastIndex = 0;
      importPath = importRegex.exec(anImport)[1];
      fullImportPath = path.join(path.dirname(file), importPath);
      imported.push(fullImportPath);
    }
  }
  baseFiles = _.difference(allFiles, imported);
  logger.debug("Base files for LESS are:\n" + (baseFiles.join('\n')));
  return baseFiles;
};

getImportFilePath = function(baseFile, importPath) {
  return path.join(path.dirname(baseFile), importPath);
};

module.exports = {
  base: "less",
  type: "css",
  defaultExtensions: ["less"],
  partialKeepsExtension: true,
  canFullyImportCSS: true,
  importRegex: importRegex,
  compile: compile,
  determineBaseFiles: determineBaseFiles,
  getImportFilePath: getImportFilePath,
  setCompilerLib: setCompilerLib
};
