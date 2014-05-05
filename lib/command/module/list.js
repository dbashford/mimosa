var childProcess, color, http, list, logger, moduleMetadata, printResults, register;

http = require('http');

color = require('ansi-color').set;

logger = require('logmimosa');

childProcess = require('child_process');

moduleMetadata = require('../../modules').installedMetadata;

printResults = function(mods, opts) {
  var asArray, data, dep, field, fields, gap, headline, installed, longestModName, m, mod, name, ownedMods, spaces, spacing, verbose, version, _i, _j, _k, _l, _len, _len1, _len2, _len3;
  verbose = opts.verbose;
  installed = opts.installed;
  longestModName = 0;
  ownedMods = [];
  for (_i = 0, _len = mods.length; _i < _len; _i++) {
    mod = mods[_i];
    if (mod.name.length > longestModName) {
      longestModName = mod.name.length;
    }
    mod.installed = '';
    for (_j = 0, _len1 = moduleMetadata.length; _j < _len1; _j++) {
      m = moduleMetadata[_j];
      if (m.name === mod.name) {
        if (mod.version === m.version) {
          mod.installed = m.version;
        } else {
          mod.installed = color(m.version, "red");
          mod.site = color("      " + mod.site, "green+bold");
        }
        ownedMods.push(mod);
      }
    }
  }
  mods = mods.filter(function(mod) {
    var owned, _k, _len2;
    for (_k = 0, _len2 = ownedMods.length; _k < _len2; _k++) {
      owned = ownedMods[_k];
      if (owned.name === mod.name) {
        return false;
      }
    }
    return true;
  });
  mods = installed ? (logger.green("  The following is a list of the Mimosa modules currently installed.\n"), ownedMods) : (logger.green("  The following is a list of the Mimosa modules in NPM.\n"), ownedMods.concat(mods));
  gap = new Array(longestModName - 2).join(' ');
  logger.blue("  Name" + gap + "Version     Updated              Have?       Website");
  fields = [['name', longestModName + 2], ['version', 13], ['updated', 22], ['installed', 13], ['site', 65]];
  for (_k = 0, _len2 = mods.length; _k < _len2; _k++) {
    mod = mods[_k];
    headline = "  ";
    for (_l = 0, _len3 = fields.length; _l < _len3; _l++) {
      field = fields[_l];
      name = field[0];
      spacing = field[1];
      data = mod[name];
      headline += data;
      spaces = spacing - (data + "").length;
      if (spaces < 1) {
        spaces = 2;
      }
      headline += new Array(spaces).join(' ');
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
    logger.green("\n  To view more module details, execute \'mimosa mod:search -v\' for \'verbose\' logging.");
  }
  if (!installed) {
    logger.green("\n  To view only the installed Mimosa modules, add the [-i/--installed] flag: \'mimosa mod:list -i\'");
  }
  logger.green("  \n  Install modules by executing \'mimosa mod:install <<name of module>>\' \n\n");
  return process.exit(0);
};

list = function(opts) {
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  logger.green("\n  Searching Mimosa modules...\n");
  return childProcess.exec('npm config get proxy', function(error, stdout, stderr) {
    var options, proxy, request;
    options = {
      'uri': 'http://mimosa-data.herokuapp.com/modules'
    };
    proxy = stdout.replace(/(\r\n|\n|\r)/gm, '');
    if (!error && proxy !== 'null') {
      options.proxy = proxy;
    }
    request = require('request');
    return request(options, function(error, client, response) {
      var mods;
      if (error !== null) {
        console.log(error);
        return;
      }
      mods = JSON.parse(response);
      return printResults(mods, opts);
    });
  });
};

register = function(program, callback) {
  var _this = this;
  return program.command('mod:list').option("-D, --mdebug", "run in debug mode").option("-v, --verbose", "list more details about each module").option("-i, --installed", "Show just those modules that are currently installed.").description("get list of all mimosa modules in NPM").action(callback).on('--help', function() {
    logger.green('  The mod:list command will search npm for all packages and return a list');
    logger.green('  of Mimosa modules that are available for install. This command will also');
    logger.green('  inform you if your project has out of date modules.');
    logger.blue('\n    $ mimosa mod:list\n');
    logger.green('  Pass an \'installed\' flag to only see the modules you have installed.');
    logger.blue('\n    $ mimosa mod:list --installed\n');
    logger.blue('\n    $ mimosa mod:list -i\n');
    logger.green('  Pass a \'verbose\' flag to get additional information about each module');
    logger.blue('\n    $ mimosa mod:list --verbose\n');
    return logger.blue('\n    $ mimosa mod:list -v\n');
  });
};

module.exports = function(program) {
  return register(program, list);
};
