var copySkeleton, fs, init, logger, path, register, wrench;

path = require('path');

fs = require('fs');

wrench = require('wrench');

logger = require('logmimosa');

init = function(name, opts) {
  var moduleDirPath;
  if (name == null) {
    return logger.error("Must provide a module name, ex: mimosa mod:init mimosa-moduleX");
  }
  if (name.indexOf('mimosa-') !== 0) {
    return logger.error("Your Mimosa module name isn't prefixed with 'mimosa-'.  To work properly with Mimosa, " + "modules must be prefixed with 'mimosa-', ex: 'mimosa-moduleX'.");
  }
  moduleDirPath = path.resolve(name);
  return fs.exists(moduleDirPath, function(exists) {
    if (exists) {
      logger.warn("Directory/file already exists at [[ " + moduleDirPath + " ]], will not overwrite it.");
      return process.exit(0);
    } else {
      return copySkeleton(name, opts.coffee, moduleDirPath);
    }
  });
};

copySkeleton = function(name, isCoffee, moduleDirPath) {
  var lang, npmignore, packageJson, skeletonPath;
  lang = isCoffee ? "coffee" : 'js';
  skeletonPath = path.join(__dirname, '..', '..', '..', 'skeletons', 'module', lang);
  wrench.copyDirSyncRecursive(skeletonPath, moduleDirPath, {
    excludeHiddenUnix: false
  });
  npmignore = path.join(moduleDirPath, 'npmignore');
  if (fs.existsSync(npmignore)) {
    fs.renameSync(npmignore, path.join(moduleDirPath, '.npmignore'));
  }
  packageJson = path.join(moduleDirPath, 'package.json');
  return fs.readFile(packageJson, 'ascii', function(err, text) {
    text = text.replace('???', name);
    return fs.writeFile(packageJson, text, function(err) {
      var readme;
      readme = path.join(moduleDirPath, 'README.md');
      return fs.readFile(readme, 'ascii', function(err, text) {
        text = text.replace(/\?\?\?/g, name);
        return fs.writeFile(readme, text, function(err) {
          logger.success(("Module skeleton successfully placed in " + name + " directory. The first thing you'll") + (" want to do is go into " + name + path.sep + "package.json and replace the placeholders."));
          return process.exit(0);
        });
      });
    });
  });
};

register = function(program, callback) {
  var _this = this;
  return program.command('mod:init [name]').option("-D, --debug", "run in debug mode").option("-c, --coffee", "get a coffeescript version of the skeleton").description("create a Mimosa module skeleton in the named directory").action(callback).on('--help', function() {
    logger.green('  The mod:init command will create a directory for the name given, and place a starter');
    logger.green('  module skeleton into the directory.  If a directory for the name given already exists');
    logger.green('  Mimosa will place the module skeleton inside of it.');
    logger.blue('\n    $ mimosa mod:init [nameOfModule]\n');
    logger.green('  The default skeleton is written in JavaScript.  If you want a skeleton delivered');
    return logger.green('  in CoffeeScript add a \'coffee\' flag.');
  });
};

module.exports = function(program) {
  return register(program, init);
};
