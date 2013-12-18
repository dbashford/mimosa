"use strict";
var compile, compilerLib, determineBaseFiles, fs, getImportFilePath, importRegex, libName, logger, path, setCompilerLib, _;

fs = require('fs');

path = require('path');

_ = require('lodash');

logger = require('logmimosa');

importRegex = /@import[\s\t]*[\(]?[\s\t]*['"]?([a-zA-Z0-9*\/\.\-\_]*)[\s\t]*[\n;\s'")]?/g;

compilerLib = null;

libName = "stylus";

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

compile = function(file, config, options, done) {
  var cb, fileName, stylusSetup, text, _ref, _ref1, _ref2;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  text = file.inputFileText;
  fileName = file.inputFileName;
  cb = function(err, css) {
    if (logger.isDebug) {
      logger.debug("Finished Stylus compile for file [[ " + fileName + " ]], errors?  " + (err != null));
    }
    return done(err, css);
  };
  logger.debug("Compiling Stylus file [[ " + fileName + " ]]");
  stylusSetup = compilerLib(text).include(path.dirname(fileName)).include(config.watch.sourceDir).set('compress', false).set('filename', fileName).set('include css', true);
  if (config.stylus.url) {
    stylusSetup.define('url', compilerLib.url(config.stylus.url));
  }
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

determineBaseFiles = function(allFiles) {
  var anImport, baseFiles, file, fullFilePath, fullImportPath, importPath, imported, imports, _i, _j, _k, _len, _len1, _len2;
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
      for (_k = 0, _len2 = allFiles.length; _k < _len2; _k++) {
        fullFilePath = allFiles[_k];
        if (fullFilePath.indexOf(fullImportPath) === 0) {
          fullImportPath += path.extname(fullFilePath);
          break;
        }
      }
      imported.push(fullImportPath);
    }
  }
  baseFiles = _.difference(allFiles, imported);
  if (logger.isDebug) {
    logger.debug("Base files for Stylus are:\n" + (baseFiles.join('\n')));
  }
  return baseFiles;
};

getImportFilePath = function(baseFile, importPath) {
  return path.join(path.dirname(baseFile), importPath);
};

module.exports = {
  base: "stylus",
  type: "css",
  defaultExtensions: ["styl"],
  canFullyImportCSS: true,
  importRegex: importRegex,
  compile: compile,
  determineBaseFiles: determineBaseFiles,
  getImportFilePath: getImportFilePath,
  setCompilerLib: setCompilerLib
};
