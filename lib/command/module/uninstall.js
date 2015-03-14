var deleteMod, register;

deleteMod = function(name, opts) {
  var currentDir, err, exec, found, fs, logger, mimosaPath, mod, moduleMetadata, pack, path, uninstallString, _i, _len,
    _this = this;
  path = require("path");
  fs = require("fs");
  exec = require("child_process").exec;
  logger = require("logmimosa");
  moduleMetadata = require("../../modules").installedMetadata;
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  if (name == null) {
    try {
      pack = require(path.join(process.cwd(), "package.json"));
    } catch (_error) {
      err = _error;
      return logger.error("Unable to find package.json, or badly formatted: " + err);
    }
    if (pack.name == null) {
      return logger.error("package.json missing either name or version");
    }
    name = pack.name;
  }
  if (name.indexOf("mimosa-") !== 0) {
    return logger.error("Can only delete 'mimosa-' prefixed modules with mod:uninstall (ex: mimosa-server).");
  }
  found = false;
  for (_i = 0, _len = moduleMetadata.length; _i < _len; _i++) {
    mod = moduleMetadata[_i];
    if (mod.name === name) {
      found = true;
      break;
    }
  }
  if (!found) {
    return logger.error("Module named [[ " + name + " ]] is not currently installed so it cannot be uninstalled.");
  }
  currentDir = process.cwd();
  mimosaPath = path.join(__dirname, "..", "..");
  process.chdir(mimosaPath);
  uninstallString = "npm uninstall " + name + " --save";
  return exec(uninstallString, function(err, sout, serr) {
    if (err) {
      logger.error(err);
    } else {
      if (serr) {
        logger.error(serr);
      }
      logger.success("Uninstall of [[ " + name + " ]] successful");
    }
    process.chdir(currentDir);
    return process.exit(0);
  });
};

register = function(program) {
  var _this = this;
  return program.command("mod:uninstall [name]").option("-D, --mdebug", "run in debug mode").description("uninstall a Mimosa module from your installed Mimosa").action(deleteMod).on("--help", function() {
    var logger;
    logger = require("logmimosa");
    logger.green("  The \'mod:uninstall\' command will delete a Mimosa module from your Mimosa install. This does");
    logger.green("  not delete anything from any of your projects, but it removes the ability for all projects");
    logger.green("  using Mimosa to utilize the removed module. You can retrieve the list of installed modules ");
    logger.green("  using \'mod:list\'.");
    return logger.blue("\n    $ mimosa mod:uninstall mimosa-server\n");
  });
};

module.exports = register;
