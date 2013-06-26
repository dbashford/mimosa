var buildConfig, copyConfig, fs, logger, path, register;

path = require('path');

fs = require('fs');

logger = require('logmimosa');

buildConfig = require('../util/config-builder');

copyConfig = function(opts) {
  var configText, currPath;
  if (opts.debug) {
    logger.setDebug();
    process.env.DEBUG = true;
  }
  currPath = path.join(path.resolve(''), "mimosa-config.coffee");
  if (fs.existsSync(currPath)) {
    logger.warn("A mimosa-config.coffee already exists in this directory.  Will not overwrite.  Please navigate to a directory that does not contain a mimosa-config.");
  } else {
    configText = buildConfig();
    logger.debug("Writing config file to " + currPath);
    fs.writeFileSync(currPath, configText, 'ascii');
    logger.success("Copied default config file into current directory.");
  }
  return process.exit(0);
};

register = function(program, callback) {
  var _this = this;
  return program.command('config').option("-D, --debug", "run in debug mode").description("copy the default Mimosa config into the current folder").action(callback).on('--help', function() {
    logger.green('  The config command will copy the default Mimosa config to the current directory.');
    logger.green('  There are no options for the config command.');
    return logger.blue('\n    $ mimosa config\n');
  });
};

module.exports = function(program) {
  return register(program, copyConfig);
};
