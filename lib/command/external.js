var Cleaner, Watcher, configurer, logger, modules;

modules = require('../modules');

configurer = require('../util/configurer');

Watcher = require('../util/watcher');

Cleaner = require('../util/cleaner');

logger = require('logmimosa');

module.exports = function(program) {
  var mod, _i, _len, _ref, _results;
  _ref = modules.modulesWithCommands();
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    mod = _ref[_i];
    _results.push(mod.registerCommand(program, function(buildFirst, callback) {
      var _this = this;
      return configurer({}, function(config, mods) {
        if (buildFirst) {
          config.isClean = true;
          return new Cleaner(config, mods, function() {
            config.isClean = false;
            return new Watcher(config, mods, false, function() {
              logger.success("Finished build");
              return callback(config);
            });
          });
        } else {
          return callback(config);
        }
      });
    }));
  }
  return _results;
};
