"use strict";
var path, _, _compile, _compilerLib, _config, _init;

path = require('path');

_ = require('lodash');

_compilerLib = null;

_config = {};

_init = function(conf) {
  return _config = conf.iced;
};

_compile = function(file, cb) {
  var conf, err, error, output, sourceMap, _ref, _ref1, _ref2;
  conf = _.extend({}, _config, {
    sourceFiles: [path.basename(file.inputFileName) + ".src"]
  });
  conf.literate = _compilerLib.helpers.isLiterate(file.inputFileName);
  if (conf.sourceMap) {
    if (((_ref = conf.sourceMapExclude) != null ? _ref.indexOf(file.inputFileName) : void 0) > -1) {
      conf.sourceMap = false;
    } else if ((conf.sourceMapExcludeRegex != null) && file.inputFileName.match(conf.sourceMapExcludeRegex)) {
      conf.sourceMap = false;
    }
  }
  try {
    output = _compilerLib.compile(file.inputFileText, conf);
    if (output.v3SourceMap) {
      sourceMap = output.v3SourceMap;
      output = output.js;
    }
  } catch (_error) {
    err = _error;
    error = "" + err + ", line " + ((_ref1 = err.location) != null ? _ref1.first_line : void 0) + ", column " + ((_ref2 = err.location) != null ? _ref2.first_column : void 0);
  }
  return cb(error, output, _config, sourceMap);
};

module.exports = {
  base: "iced",
  type: "javascript",
  defaultExtensions: ["iced"],
  cleanUpSourceMaps: true,
  libName: 'iced-coffee-script',
  init: _init,
  compile: _compile,
  compilerLib: _compilerLib,
  config: _config
};
