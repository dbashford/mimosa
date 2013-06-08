var color, compilerCentral, logger;

color = require('ansi-color').set;

logger = require('logmimosa');

compilerCentral = require('../modules/compilers');

exports.projectPossibilities = function(callback) {
  var comp, compilers, _i, _len, _ref, _results,
    _this = this;

  compilers = compilerCentral.compilersByType();
  _ref = compilers.css;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    comp = _ref[_i];
    if (comp.checkIfExists != null) {
      comp.checkIfExists(function(exists) {
        if (!exists) {
          logger.debug("Compiler for file [[ " + comp.fileName + " ]], is not installed/available");
          comp.prettyName = comp.prettyName + color(" (This is not installed and would need to be before use)", "yellow+bold");
        }
        return callback(compilers);
      });
      break;
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

exports.deepFreeze = function(o) {
  var _this = this;

  if (o != null) {
    Object.freeze(o);
    return Object.getOwnPropertyNames(o).forEach(function(prop) {
      if (o.hasOwnProperty(prop) && o[prop] !== null && (typeof o[prop] === "object" || typeof o[prop] === "function") && !Object.isFrozen(o[prop])) {
        return exports.deepFreeze(o[prop]);
      }
    });
  }
};
