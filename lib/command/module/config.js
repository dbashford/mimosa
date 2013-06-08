var config, getModule, logger, register;

logger = require('logmimosa');

config = function(name, opts) {
  var mod, text;

  if (name == null) {
    return logger.error("Must provide a module name, ex: mimosa mod:config mimosa-moduleX");
  }
  mod = getModule(name);
  if (mod == null) {
    mod = getModule("mimosa-" + name);
  }
  if (mod != null) {
    if (mod.placeholder) {
      text = mod.placeholder();
      logger.green("" + text + "\n\n");
    } else {
      logger.info("Module [[ " + name + " ]] has no configuration");
    }
  } else {
    return logger.error("Could not find module named [[ " + name + " ]]");
  }
  return process.exit(0);
};

getModule = function(name) {
  var err;

  try {
    return require(name);
  } catch (_error) {
    err = _error;
    return logger.debug("Did not find module named [[ " + name + " ]]");
  }
};

register = function(program, callback) {
  var _this = this;

  return program.command('mod:config [name]').option("-D, --debug", "run in debug mode").description("Print out the configuration snippet for a module to the console").action(callback).on('--help', function() {
    logger.green('  The mod:config command will print out the default commented out CoffeeScript snippet ');
    logger.green('  for the given named Mimosa module. If there is already a mimosa-config.coffee in the');
    logger.green('  current directory, Mimosa will not copy the file in.');
    return logger.blue('\n    $ mimosa mod:config [nameOfModule]\n');
  });
};

module.exports = function(program) {
  return register(program, config);
};
