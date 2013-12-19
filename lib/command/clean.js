var Cleaner, clean, configurer, fs, logger, register, wrench,
  _this = this;

fs = require('fs');

wrench = require('wrench');

logger = require('logmimosa');

Cleaner = require('../util/cleaner');

configurer = require('../util/configurer');

clean = function(opts) {
  var _this = this;
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  opts.clean = true;
  return configurer(opts, function(config, modules) {
    if (opts.force) {
      if (fs.existsSync(config.watch.compiledDir)) {
        logger.info("Forcibly removing the entire directory [[ " + config.watch.compiledDir + " ]]");
        wrench.rmdirSyncRecursive(config.watch.compiledDir);
        return logger.success("[[ " + config.watch.compiledDir + " ]] has been removed");
      } else {
        return logger.success("Compiled directory already deleted");
      }
    } else {
      config.isClean = true;
      return new Cleaner(config, modules, function() {
        logger.success("[[ " + config.watch.compiledDir + " ]] has been cleaned.");
        return process.exit(0);
      });
    }
  });
};

register = function(program, callback) {
  return program.command('clean').option("-f, --force", "completely delete your compiledDir").option("-P, --profile <profileName>", "select a mimosa profile").option("-D, --mdebug", "run in debug mode").description("clean out all of the compiled assets from the compiled directory").action(callback).on('--help', function() {
    logger.green('  The clean command will remove all of the compiled assets from the configured compiledDir. After');
    logger.green('  the assets are deleted, any empty directories left over are also removed. Mimosa will also remove any');
    logger.green('  Mimosa copied assets, like template libraries. It will not remove anything that did not originate');
    logger.green('  from the source directory.');
    logger.blue('\n    $ mimosa clean\n');
    logger.green('  In the course of development, some files get left behind that no longer have counterparts in your');
    logger.green('  source directories.  If you have \'mimosa watch\' turned off when you delete a file, for instance,');
    logger.green('  the compiled version of that file will not get removed from your compiledDir, and \'mimosa clean\'');
    logger.green('  will leave it alone because it does not recognize it as coming from mimosa.  If you want to ');
    logger.green('  forcibly remove the entire compiledDir, use the \'force\' flag.');
    logger.blue('\n    $ mimosa clean -force');
    logger.blue('    $ mimosa clean -f\n');
    logger.green('  Pass a \'profile\' flag and the name of a Mimosa profile to run with mimosa config overrides from a profile.');
    logger.blue('\n    $ mimosa clean --profile build');
    return logger.blue('    $ mimosa clean -P build');
  });
};

module.exports = function(program) {
  return register(program, clean);
};
