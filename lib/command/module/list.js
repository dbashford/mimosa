var fs, list, logger, moduleMetadata, path, register;

path = require('path');

fs = require('fs');

logger = require('logmimosa');

moduleMetadata = require('../../modules').installedMetadata;

list = function(opts) {
  var asArray, data, dep, field, fields, headline, mod, n, name, spaces, spacing, version, _i, _j, _k, _len, _len1;

  if (opts.debug) {
    logger.setDebug();
    process.env.DEBUG = true;
  }
  logger.green("\n  The following is a list of the Mimosa modules you have installed.\n");
  logger.blue("  Name                      Version         Website");
  fields = [['name', 25], ['version', 15], ['site', 65]];
  for (_i = 0, _len = moduleMetadata.length; _i < _len; _i++) {
    mod = moduleMetadata[_i];
    headline = "  ";
    for (_j = 0, _len1 = fields.length; _j < _len1; _j++) {
      field = fields[_j];
      name = field[0];
      spacing = field[1];
      data = mod[name];
      headline += data;
      spaces = spacing - (data + "").length;
      if (spaces < 1) {
        spaces = 2;
      }
      for (n = _k = 0; 0 <= spaces ? _k <= spaces : _k >= spaces; n = 0 <= spaces ? ++_k : --_k) {
        headline += " ";
      }
    }
    logger.green(headline);
    if (opts.verbose) {
      console.log("  Description:  " + mod.desc);
      if (mod.dependencies != null) {
        asArray = (function() {
          var _ref, _results;

          _ref = mod.dependencies;
          _results = [];
          for (dep in _ref) {
            version = _ref[dep];
            _results.push("" + dep + "@" + version);
          }
          return _results;
        })();
        console.log("  Dependencies: " + (asArray.join(', ')));
      }
      console.log("");
    }
  }
  if (!opts.verbose) {
    logger.green("\n  To view more module details, execute \'mimosa mod:list -v\' for \'verbose\' logging. \n");
  }
  return process.exit(0);
};

register = function(program, callback) {
  var _this = this;

  return program.command('mod:list').option("-D, --debug", "run in debug mode").option("-v, --verbose", "list more details about each module").description("list all of your currently installed Mimosa modules").action(callback).on('--help', function() {
    logger.green('  The mod:list command will list all of the Mimosa modules you currently have installed');
    logger.green('  and include information like version, a description, and where the module can be found');
    logger.green('  so you can read up on it.');
    logger.blue('\n    $ mimosa mod:list\n');
    logger.green('  Pass a \'verbose\' flag to get additional information about each module');
    logger.blue('\n    $ mimosa mod:list --verbose\n');
    return logger.blue('\n    $ mimosa mod:list -v\n');
  });
};

module.exports = function(program) {
  return register(program, list);
};
