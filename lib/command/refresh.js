var exec, fs, logger, path, register, update, _findPackageJsonPath, _installDependencies, _uninstallDependencies;

path = require('path');

fs = require('fs');

exec = require('child_process').exec;

logger = require('logmimosa');

update = function(opts) {
  var clientPackageJson, clientPackageJsonPath, currentDir, done, jspacks, mimosaPackageJson, mimosaPackageJsonPath, pack, _i, _len;

  logger.warn("The refresh command has been deprecated and will be removed in a future release.\nIf you use the refresh command and rather it not be removed, please travel over to\nhttps://github.com/dbashford/mimosa/issues/205 and let me know that you'd like\nto keep it.");
  if (opts.debug) {
    logger.setDebug();
    process.env.DEBUG = true;
  }
  clientPackageJsonPath = _findPackageJsonPath();
  if (clientPackageJsonPath == null) {
    return logger.info("Did not find package.json.  Nothing to update.");
  }
  logger.debug("client package.json path: [[ " + clientPackageJsonPath + " ]]");
  clientPackageJson = require(clientPackageJsonPath);
  mimosaPackageJsonPath = path.join(__dirname, '..', '..', 'skeleton', 'package.json');
  logger.debug("mimosa package.json path: [[ " + mimosaPackageJsonPath + " ]]");
  mimosaPackageJson = require(mimosaPackageJsonPath);
  currentDir = process.cwd();
  process.chdir(path.dirname(clientPackageJsonPath));
  done = function() {
    process.chdir(currentDir);
    logger.success("Finished.  You are all up to date!");
    return process.exit(0);
  };
  jspacks = ['iced-coffee-script', 'LiveScript', 'typescript'];
  for (_i = 0, _len = jspacks.length; _i < _len; _i++) {
    pack = jspacks[_i];
    if ((clientPackageJson.dependencies[pack] == null) && (mimosaPackageJson.dependencies[pack] != null)) {
      logger.debug("Removing " + pack + " from list of dependencies to install.");
      delete mimosaPackageJson.dependencies[pack];
    }
  }
  return _uninstallDependencies(mimosaPackageJson.dependencies, clientPackageJson.dependencies, function() {
    return _installDependencies(mimosaPackageJson.dependencies, clientPackageJson.dependencies, done);
  });
};

_uninstallDependencies = function(deps, clientDeps, callback) {
  var name, present, version,
    _this = this;

  present = [];
  for (name in deps) {
    version = deps[name];
    if (clientDeps[name]) {
      logger.info("Un-installing node package: " + name + ":" + clientDeps[name]);
      present.push(name);
    }
  }
  if (present.length > 0) {
    return exec("npm uninstall " + (present.join(' ')) + " --save", function(err, sout, serr) {
      if (err) {
        if (err) {
          return logger.info(err);
        }
      } else {
        logger.success("Uninstall successful");
        return callback(deps);
      }
    });
  } else {
    return callback(deps);
  }
};

_installDependencies = function(deps, origClientDeps, done) {
  var installString, name, names, version,
    _this = this;

  names = (function() {
    var _results;

    _results = [];
    for (name in deps) {
      version = deps[name];
      if (origClientDeps[name] == null) {
        continue;
      }
      logger.info("Installing node package: " + name + ":" + version);
      if (version.indexOf("github.com") > -1) {
        _results.push(version);
      } else {
        _results.push("" + name + "@" + version);
      }
    }
    return _results;
  })();
  installString = "npm install " + (names.join(' ')) + " --save";
  logger.debug("Installing, npm command is '" + installString + "'");
  return exec(installString, function(err, sout, serr) {
    if (err) {
      logger.info(err);
    } else {
      logger.success("Install successful");
    }
    logger.debug("NPM INSTALL standard out\n" + sout);
    logger.debug("NPM INSTALL standard err\n" + serr);
    return done();
  });
};

_findPackageJsonPath = function(packagePath) {
  var dirname;

  if (packagePath == null) {
    packagePath = path.resolve('package.json');
  }
  if (fs.existsSync(packagePath)) {
    return packagePath;
  } else {
    packagePath = path.join(path.dirname(packagePath), '..', 'package.json');
    logger.debug("Didn not find package.json, trying [[ " + packagePath + " ]]");
    dirname = path.dirname(packagePath);
    if (dirname.indexOf(path.sep) === dirname.lastIndexOf(path.sep)) {
      return null;
    } else {
      return _findPackageJsonPath(packagePath);
    }
  }
};

register = function(program, callback) {
  var _this = this;

  return program.command('refresh').option("-D, --debug", "run in debug mode").description("refresh all the node libraries that Mimosa packaged into your application").action(callback).on('--help', function() {
    logger.green('  The update command keeps you from having to deal with updating your project\'s node_modules ');
    logger.green('  directory when Mimosa updates its libraries.  For instance, if Express updates to a new');
    logger.green('  version this command will refresh your package.json and install new node packages so you');
    logger.green('  can take advantage of the new Express functionality without having to deal with installing');
    logger.green('  it yourself.');
    return logger.blue('\n    $ mimosa update\n');
  });
};

module.exports = function(program) {
  return register(program, update);
};
