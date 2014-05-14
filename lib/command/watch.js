var register, watch;

watch = function(opts) {
  var configurer, fileUtils, fs, logger;
  fs = require('fs');
  logger = require('logmimosa');
  configurer = require('../util/configurer');
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  opts.watch = true;
  if (opts.cleanall) {
    opts.clean = true;
    fileUtils = require('../util/file');
    fileUtils.removeDotMimosa();
    logger.info("Removed .mimosa directory.");
  }
  return configurer(opts, function(config, modules) {
    var Cleaner, instWatcher, wrench;
    instWatcher = function() {
      var Watcher;
      config.isClean = false;
      Watcher = require('../util/watcher');
      return new Watcher(config, modules, true);
    };
    if (opts["delete"]) {
      if (fs.existsSync(config.watch.compiledDir)) {
        wrench = require('wrench');
        wrench.rmdirSyncRecursive(config.watch.compiledDir);
        logger.success("[[ " + config.watch.compiledDir + " ]] has been removed");
        return instWatcher();
      }
    } else if (opts.clean || config.needsClean) {
      config.isClean = true;
      Cleaner = require('../util/cleaner');
      return new Cleaner(config, modules, instWatcher);
    } else {
      return instWatcher();
    }
  });
};

register = function(program, callback) {
  return program.command('watch').description("watch the filesystem and compile assets").option("-s, --server", "run a server that will serve up the assets in the compiled directory").option("-o, --optimize", "run require.js optimization after each js file compile").option("-m, --minify", "minify each asset as it is compiled using uglify").option("-c, --clean", "clean the compiled directory before the watch begins, this forces a recompile of all your assets").option("-C, --cleanall", "clean the compiled directory and the .mimosa directory before the watch begins").option("-d, --delete", "remove the compiled directory entirely before starting").option("-P, --profile <profileName>", "select a mimosa profile").option("-D, --mdebug", "run in debug mode").action(callback).on('--help', function() {
    var logger;
    logger = require('logmimosa');
    logger.green('  The watch command will observe your source directory and compile or copy your assets when they change.');
    logger.green('  When the watch command starts up, it will make an initial pass through your assets and compile or copy');
    logger.green('  any assets that are newer then their companion compiled assets in the compiled directory.  The watch');
    logger.green('  command will remain running when executed, and must be terminated with CNTL-C.');
    logger.blue('\n    $ mimosa watch\n');
    logger.green('  Pass a \'server\' flag and Mimosa will start-up a server that will serve up the assets Mimosa compiles.');
    logger.green('  You have the opportunity, via Mimosa\'s config, to provide Mimosa a hook to your own server if you have');
    logger.green('  one.  If you do not have a server, Mimosa will use an embedded server to serve up the assets.  Server');
    logger.green('  configuration options and explanations can be found in the \'server\' settings in the mimosa-config.');
    logger.blue('\n    $ mimosa watch --server');
    logger.blue('    $ mimosa watch -s\n');
    logger.green('  Pass a \'clean\' flag and Mimosa will first clean out all your assets before starting the watch.  This');
    logger.green('  has the effect of forcing a recompile of all of your assets.');
    logger.blue('\n    $ mimosa watch --clean');
    logger.blue('    $ mimosa watch -c\n');
    logger.green('  Pass a \'cleanall\' flag and Mimosa will first clean out all your assets before starting the watch.  This');
    logger.green('  has the effect of forcing a recompile of all of your assets. This clean will also remove the .mimosa directory.');
    logger.blue('\n    $ mimosa watch --cleanall');
    logger.blue('    $ mimosa watch -C\n');
    logger.green('  Pass a \'delete\' flag and Mimosa will first remove the compiled directory before starting the watch.');
    logger.blue('\n    $ mimosa watch --delete');
    logger.blue('    $ mimosa watch -d\n');
    logger.green('  Pass an \'optimize\' flag and Mimosa will use requirejs to optimize your assets and provide you with');
    logger.green('  single files for the named requirejs modules.  It will do this any time a JavaScript asset is changed.');
    logger.blue('\n    $ mimosa watch --optimize');
    logger.blue('    $ mimosa watch -o\n');
    logger.green('  Pass an \'minify\' flag and Mimosa will use uglify to minify/compress your assets as they are compiled.');
    logger.green('  You can provide exclude, files you do not want to minify, in the mimosa-config.  If you run \'minify\' ');
    logger.green('  and \'optimize\' at the same time, optimize will not run the uglify portion of its processing which occurs as');
    logger.green('  a separate step after everything has compiled and does not allow control of what gets uglified. Use \'optimize\'');
    logger.green('  and \'minify\' together if you need to control which files get mangled by uglify (because sometimes uglify');
    logger.green('  can break them) but you still want everything together in a single file.');
    logger.blue('\n    $ mimosa watch --minify');
    logger.blue('    $ mimosa watch -m\n');
    logger.green('  Pass a \'profile\' flag and the name of a Mimosa profile to run with.');
    logger.blue('\n    $ mimosa clean --profile build');
    return logger.blue('    $ mimosa clean -P build');
  });
};

module.exports = function(program) {
  return register(program, watch);
};
