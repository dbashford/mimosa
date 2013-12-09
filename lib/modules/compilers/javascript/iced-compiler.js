"use strict";
var compilerLib, icedConfig, init, libName, path, prefix, setCompilerLib, _;

path = require('path');

_ = require('lodash');

compilerLib = null;

libName = 'iced-coffee-script';

icedConfig = {};

setCompilerLib = function(_compilerLib) {
  return compilerLib = _compilerLib;
};

init = function(conf) {
  return icedConfig = conf.iced;
};

prefix = function(file, cb) {
  var conf, err, error, output, sourceMap, _ref, _ref1, _ref2;
  if (!compilerLib) {
    compilerLib = require(libName);
  }
  conf = _.extend({}, icedConfig, {
    sourceFiles: [path.basename(file.inputFileName) + ".src"]
  });
  conf.literate = compilerLib.helpers.isLiterate(file.inputFileName);
  if (conf.sourceMap) {
    if (((_ref = conf.sourceMapExclude) != null ? _ref.indexOf(file.inputFileName) : void 0) > -1) {
      conf.sourceMap = false;
    } else if ((conf.sourceMapExcludeRegex != null) && file.inputFileName.match(conf.sourceMapExcludeRegex)) {
      conf.sourceMap = false;
    }
  }
  try {
    output = compilerLib.compile(file.inputFileText, conf);
    if (output.v3SourceMap) {
      sourceMap = output.v3SourceMap;
      output = output.js;
    }
  } catch (_error) {
    err = _error;
    error = "" + err + ", line " + ((_ref1 = err.location) != null ? _ref1.first_line : void 0) + ", column " + ((_ref2 = err.location) != null ? _ref2.first_column : void 0);
  }
  return cb(error, output, icedConfig, sourceMap);
};

module.exports = {
  base: "iced",
  type: "javascript",
  defaultExtensions: ["iced"],
  cleanUpSourceMaps: true,
  init: init,
  compile: prefix,
  setCompilerLib: setCompilerLib,
  config: icedConfig
};
