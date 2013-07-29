var buildConfig, copyConfig, fs, logger, path, register;

path = require('path');

fs = require('fs');

logger = require('logmimosa');

buildConfig = require('../util/config-builder');

copyConfig = function(opts) {
  var conf, currDefaultsPath, mimosaConfigPath;
  if (opts.debug) {
    logger.setDebug();
    process.env.DEBUG = true;
  }
  conf = buildConfig();
  currDefaultsPath = path.join(path.resolve(''), "mimosa-config.defaults.coffee");
  logger.debug("Writing config defaults file to " + currDefaultsPath);
  fs.writeFileSync(currDefaultsPath, conf, 'ascii');
  logger.success("Copied mimosa-config.defaults.coffee into current directory.");
  mimosaConfigPath = path.join(path.resolve(''), "mimosa-config.coffee");
  if (fs.existsSync(mimosaConfigPath)) {
    logger.info("Not writing mimosa-config.coffee file as one exists already.");
  } else {
    logger.debug("Writing config file to " + mimosaConfigPath);
    fs.writeFileSync(mimosaConfigPath, conf, 'ascii');
    logger.success("Copied mimosa-config.coffee into current directory.");
  }
  return process.exit(0);
};

register = function(program, callback) {
  var _this = this;
  return program.command('config').option("-D, --debug", "run in debug mode").description("copy the default Mimosa config into the current folder").action(callback).on('--help', function() {
    logger.green('  The config command will copy the default Mimosa config to the current directory.');
    logger.green('  And also copy a defaults file to keep as reference should you desire to alter and.');
    logger.green('  shrink the mimosa-config.');
    return logger.blue('\n    $ mimosa config\n');
  });
};

module.exports = function(program) {
  return register(program, copyConfig);
};
