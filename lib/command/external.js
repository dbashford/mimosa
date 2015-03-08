var retrieveConfig;

retrieveConfig = function(opts, callback) {
  var configurer, logger;
  logger = require('logmimosa');
  if (opts.mdebug) {
    logger.setDebug();
    process.env.DEBUG = true;
  }
  configurer = require('../util/configurer');
  return configurer(opts, function(config, mods) {
    var Cleaner, Watcher;
    if (opts.buildFirst) {
      Cleaner = require('../util/cleaner');
      Watcher = require('../util/watcher');
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
};

module.exports = function(program) {
  var logger, mod, modules, _i, _len, _ref, _results;
  modules = require('../modules');
  _ref = modules.modulesWithCommands();
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    mod = _ref[_i];
    logger = require('logmimosa');
    _results.push(mod.registerCommand(program, logger, retrieveConfig));
  }
  return _results;
};
