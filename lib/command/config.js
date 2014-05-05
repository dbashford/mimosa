var copyConfig, register;

copyConfig = function(opts) {
  var buildConfig, conf, currDefaultsPath, defaultsConf, fs, logger, mimosaConfigPath, mimosaConfigPathCoffee, modArray, modObj, moduleManager, outConfigText, path;
  path = require('path');
  fs = require('fs');
  logger = require('logmimosa');
  buildConfig = require('../util/config-builder');
  moduleManager = require('../modules');
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  conf = buildConfig();
  currDefaultsPath = path.join(path.resolve(''), "mimosa-config-documented.coffee");
  logger.debug("Writing config defaults file to " + currDefaultsPath);
  defaultsConf = "# The following is a version of the mimosa-config with all of\n# the defaults listed. This file is meant for reference only.\n\n" + conf;
  fs.writeFileSync(currDefaultsPath, defaultsConf, 'ascii');
  if (!opts.suppress) {
    logger.success("Copied [[ mimosa-config-documented.coffee ]] into current directory.");
  }
  mimosaConfigPath = path.join(path.resolve(''), "mimosa-config.js");
  mimosaConfigPathCoffee = path.join(path.resolve(''), "mimosa-config.coffee");
  if (fs.existsSync(mimosaConfigPath) || fs.existsSync(mimosaConfigPathCoffee)) {
    if (!opts.suppress) {
      logger.info("Not writing mimosa-config file as one exists already.");
    }
  } else {
    logger.debug("Writing config file to " + mimosaConfigPath);
    outConfigText = moduleManager.configModuleString ? (modArray = JSON.parse(moduleManager.configModuleString), modObj = {
      modules: modArray
    }, "exports.config = " + JSON.stringify(modObj, null, 2)) : (modObj = {
      modules: ['copy', 'jshint', 'csslint', 'server', 'require', 'minify-js', 'minify-css', 'live-reload', 'bower']
    }, "exports.config = " + JSON.stringify(modObj, null, 2));
    fs.writeFileSync(mimosaConfigPath, outConfigText, 'ascii');
    if (!opts.suppress) {
      logger.success("Copied [[ mimosa-config.js ]] into current directory.");
    }
  }
  return process.exit(0);
};

register = function(program, callback) {
  return program.command('config').option("-D, --mdebug", "run in debug mode").option("-s, --suppress", "suppress info message").description("copy the default Mimosa config into the current folder").action(callback).on('--help', function() {
    var logger;
    logger = require('logmimosa');
    logger.green('  The config command will create a mimosa-config.js in the current directory. It will');
    logger.green('  also create a mimosa-config-documented.coffee which contains all of the various');
    logger.green('  configuration documentation for each module that is a part of your project.');
    return logger.blue('\n    $ mimosa config\n');
  });
};

module.exports = function(program) {
  return register(program, copyConfig);
};
