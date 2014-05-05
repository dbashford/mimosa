var registerCommand;

registerCommand = function(buildFirst, isDebug, callback) {
  var configurer, logger;
  logger = require('logmimosa');
  if (callback) {
    if (isDebug) {
      logger.setDebug();
      process.env.DEBUG = true;
    }
  } else {
    callback = isDebug;
  }
  configurer = require('../util/configurer');
  return configurer({}, function(config, mods) {
    var Cleaner;
    if (buildFirst) {
      config.isClean = true;
      Cleaner = require('../util/cleaner');
      return new Cleaner(config, mods, function() {
        var Watcher;
        config.isClean = false;
        Watcher = require('../util/watcher');
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
    if (mod.registerCommand.length === 2) {
      _results.push(mod.registerCommand(program, registerCommand));
    } else {
      logger = require('logmimosa');
      _results.push(mod.registerCommand(program, logger, registerCommand));
    }
  }
  return _results;
};
