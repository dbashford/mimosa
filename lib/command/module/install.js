var currentDir, exec, fs, install, logger, mimosaPath, path, register, wrench, _doLocalInstall, _doNPMInstall, _doneNPMInstall, _installModule, _prepareForNPMInstall, _revertInstall, _testLocalInstall;

path = require('path');

fs = require('fs');

exec = require('child_process').exec;

wrench = require('wrench');

logger = require('logmimosa');

mimosaPath = path.join(__dirname, '..', '..', '..');

currentDir = process.cwd();

install = function(name, opts) {
  var dirName, err, pack;
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  if (name != null) {
    if (!((name != null) && name.indexOf('mimosa-') === 0)) {
      return logger.error("Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server).");
    }
    dirName = name.indexOf('@') > 7 ? name.substring(0, name.indexOf('@')) : name;
    return _doNPMInstall(name, dirName);
  } else {
    try {
      pack = require(path.join(currentDir, 'package.json'));
    } catch (_error) {
      err = _error;
      return logger.error("Unable to find package.json, or badly formatted: " + err);
    }
    if (!((pack.name != null) && (pack.version != null))) {
      return logger.error("package.json missing either name or version");
    }
    if (pack.name.indexOf('mimosa-') !== 0) {
      return logger.error("package.json name is [[ " + pack.name + " ]]. Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server). ");
    }
    return _doLocalInstall();
  }
};

_installModule = function(name, done) {
  var installString,
    _this = this;
  logger.info("Installing module [[ " + name + " ]] into Mimosa.");
  installString = "npm install \"" + name + "\" --save";
  return exec(installString, function(err, sout, serr) {
    if (err) {
      logger.error("Error installing module");
      logger.error(err);
    } else {
      console.log(sout);
      console.log(serr);
      logger.success("Install of [[ " + name + " ]] successful");
    }
    logger.debug("NPM INSTALL standard out\n" + sout);
    logger.debug("NPM INSTALL standard err\n" + serr);
    return done(err);
  });
};

/*
NPM Install
*/


_doNPMInstall = function(name, dirName) {
  var oldVersion;
  process.chdir(mimosaPath);
  oldVersion = _prepareForNPMInstall(dirName);
  return _installModule(name, _doneNPMInstall(dirName, oldVersion));
};

_doneNPMInstall = function(name, oldVersion) {
  return function(err) {
    var backupPath;
    if (err) {
      _revertInstall(oldVersion, name);
    }
    backupPath = path.join(mimosaPath, "node_modules", name + "_____backup");
    if (fs.existsSync(backupPath)) {
      wrench.rmdirSyncRecursive(backupPath);
    }
    process.chdir(currentDir);
    return process.exit(0);
  };
};

_prepareForNPMInstall = function(name) {
  var beginPath, endPath, mimosaPackage, mimosaPackagePath, oldVersion;
  beginPath = path.join(mimosaPath, "node_modules", name);
  oldVersion = null;
  if (fs.existsSync(beginPath)) {
    endPath = path.join(mimosaPath, "node_modules", name + "_____backup");
    wrench.copyDirSyncRecursive(beginPath, endPath);
    mimosaPackagePath = path.join(mimosaPath, 'package.json');
    mimosaPackage = require(mimosaPackagePath);
    oldVersion = mimosaPackage.dependencies[name];
    delete mimosaPackage.dependencies[name];
    logger.debug("New mimosa dependencies:\n " + (JSON.stringify(mimosaPackage, null, 2)));
    fs.writeFileSync(mimosaPackagePath, JSON.stringify(mimosaPackage, null, 2), 'ascii');
  }
  return oldVersion;
};

_revertInstall = function(oldVersion, name) {
  var backupPath, endPath, mimosaPackage, mimosaPackagePath, modPath;
  backupPath = path.join(mimosaPath, "node_modules", name + "_____backup");
  if (fs.existsSync(backupPath)) {
    endPath = path.join(mimosaPath, "node_modules", name);
    wrench.copyDirSyncRecursive(backupPath, endPath);
    mimosaPackagePath = path.join(mimosaPath, 'package.json');
    mimosaPackage = require(mimosaPackagePath);
    mimosaPackage.dependencies[name] = oldVersion;
    logger.debug("New mimosa dependencies:\n " + (JSON.stringify(mimosaPackage, null, 2)));
    return fs.writeFileSync(mimosaPackagePath, JSON.stringify(mimosaPackage, null, 2), 'ascii');
  } else {
    modPath = path.join(mimosaPath, "node_modules", name);
    if (fs.existsSync(modPath)) {
      return wrench.rmdirSyncRecursive(modPath);
    }
  }
};

/*
Local Dev Install
*/


_doLocalInstall = function() {
  return _testLocalInstall(function() {
    var dirName;
    dirName = currentDir.replace(path.dirname(currentDir) + path.sep, '');
    process.chdir(mimosaPath);
    return _installModule(currentDir, function() {
      process.chdir(currentDir);
      return process.exit(0);
    });
  });
};

_testLocalInstall = function(callback) {
  var _this = this;
  logger.info("Testing local install in place.");
  return exec("npm install", function(err, sout, serr) {
    if (err) {
      return logger.error("Could not install module locally: \n " + err);
    }
    logger.debug("NPM INSTALL standard out\n" + sout);
    logger.debug("NPM INSTALL standard err\n" + serr);
    try {
      require(currentDir);
      logger.info("Local install successful.");
      return callback();
    } catch (_error) {
      err = _error;
      logger.error("Attempted to use installed module and module failed\n" + err);
      return console.log(err);
    }
  });
};

/*
Command
*/


register = function(program, callback) {
  var _this = this;
  return program.command('mod:install [name]').option("-D, --mdebug", "run in debug mode").description("install a Mimosa module into your Mimosa").action(callback).on('--help', function() {
    logger.green('  The \'mod:install\' command will install a Mimosa module into Mimosa. It does not install');
    logger.green('  the module into your project, it just makes it available to be used by Mimosa\'s commands.');
    logger.green('  You can discover new modules using the \'mod:search\' command.  Once you know the module you');
    logger.green('  would like to install, put the name of the module after the \'mod:install\' command.');
    logger.blue('\n    $ mimosa mod:install mimosa-server\n');
    logger.green('  If there is a specific version of a module you want to use, simply append \'@\' followed by');
    logger.green('  the version information.');
    logger.blue('\n    $ mimosa mod:install mimosa-server@0.1.0\n');
    logger.green('  If you are developing a module and would like to install your local module into your local');
    logger.green('  Mimosa, then execute \'mod:install\' from the root of the module, the same location as the');
    logger.green('  package.json, without providing a name.');
    return logger.blue('\n    $ mimosa mod:install\n');
  });
};

module.exports = function(program) {
  return register(program, install);
};
