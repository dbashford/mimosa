var color, fs, logger, moduleMetadata, npm, path, printResults, register, search;

path = require('path');

fs = require('fs');

color = require('ansi-color').set;

logger = require('logmimosa');

npm = require('npm');

moduleMetadata = require('../../modules').installedMetadata;

printResults = function(mods, verbose) {
  var asArray, data, dep, field, fields, headline, mod, n, name, spaces, spacing, version, _i, _j, _k, _len, _len1;

  logger.green("  The following is a list of the Mimosa modules in NPM.\n");
  logger.blue("  Name                      Version         Updated                Installed?   Website");
  fields = [['name', 25], ['version', 15], ['updated', 22], ['installed', 12], ['site', 65]];
  for (_i = 0, _len = mods.length; _i < _len; _i++) {
    mod = mods[_i];
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
    if (verbose) {
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
  if (!verbose) {
    logger.green("\n  To view more module details, execute \'mimosa mod:search -v\' for \'verbose\' logging. \n");
  }
  logger.green("  Install modules by executing \'mimosa mod:install <<name of module>>\' \n");
  return process.exit(0);
};

search = function(opts) {
  if (opts.debug) {
    logger.setDebug();
    process.env.DEBUG = true;
  }
  logger.green("\n  Searching NPM for Mimosa modules, this might take a few seconds...\n");
  return npm.load({
    outfd: null,
    exit: false,
    loglevel: 'silent'
  }, function() {
    return npm.commands.search(['mimosa-'], true, function(err, pkgs) {
      var add, i, mods, packageNames;

      if (err) {
        return logger.error("Problem accessing NPM: " + err);
      } else {
        packageNames = Object.keys(pkgs);
        mods = [];
        i = 0;
        add = function(mod) {
          if (mod) {
            mods.push(mod);
          }
          if (++i === packageNames.length) {
            return printResults(mods, opts.verbose);
          }
        };
        return packageNames.forEach(function(pkg) {
          return npm.commands.view([pkg], true, function(err, packageInfo) {
            var data, installed, m, mod, version, _i, _len, _results;

            if (packageInfo) {
              _results = [];
              for (version in packageInfo) {
                data = packageInfo[version];
                installed = false;
                for (_i = 0, _len = moduleMetadata.length; _i < _len; _i++) {
                  m = moduleMetadata[_i];
                  if (m.name === data.name) {
                    installed = true;
                    break;
                  }
                }
                mod = {
                  name: data.name,
                  version: version,
                  site: data.homepage,
                  dependencies: data.dependencies,
                  desc: data.description,
                  updated: data.time[version].replace('T', ' ').replace(/\.\w+$/, ''),
                  installed: installed ? "yes" : "no"
                };
                _results.push(add(mod));
              }
              return _results;
            } else {
              return add(null);
            }
          });
        });
      }
    });
  });
};

register = function(program, callback) {
  var _this = this;

  return program.command('mod:search').option("-D, --debug", "run in debug mode").description("get list of all mimosa modules in NPM").option("-v, --verbose", "list more details about each module").action(callback).on('--help', function() {
    logger.green('  The mod:search command will search npm for all packages using the keyword \'mmodule\'');
    logger.green('  and return a list of all the modules that are available for install.');
    logger.blue('\n    $ mimosa mod:search\n');
    logger.green('  Pass a \'verbose\' flag to get additional information about each module');
    logger.blue('\n    $ mimosa mod:search --verbose\n');
    return logger.blue('\n    $ mimosa mod:search -v\n');
  });
};

module.exports = function(program) {
  return register(program, search);
};
