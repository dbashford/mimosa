"use strict";
var all, allInstalled, builtIns, compilers, configModuleString, configured, configuredModules, exec, file, fs, independentlyInstalled, isMimosaModuleName, locallyInstalled, locallyInstalledNames, logger, meta, metaNames, mimosaPackage, modulesWithCommands, names, newmod, path, projectNodeModules, skels, standardlyInstalled, _,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

path = require('path');

exec = require('child_process').exec;

_ = require('lodash');

logger = require('logmimosa');

skels = require('skelmimosa');

newmod = require('newmimosa');

compilers = require('./compilers');

file = require('./file');

mimosaPackage = require('../../package.json');

builtIns = ['mimosa-copy', 'mimosa-server', 'mimosa-jshint', 'mimosa-csslint', 'mimosa-require', 'mimosa-minify-js', 'mimosa-minify-css', 'mimosa-live-reload', 'mimosa-bower'];

configuredModules = null;

isMimosaModuleName = function(str) {
  return str.indexOf('mimosa-') > -1;
};

projectNodeModules = path.resolve(process.cwd(), 'node_modules');

locallyInstalled = fs.existsSync(projectNodeModules) ? _(fs.readdirSync(projectNodeModules)).select(isMimosaModuleName).select(function(dep) {
  var err;
  try {
    require(path.join(projectNodeModules, dep));
    return true;
  } catch (_error) {
    err = _error;
    logger.error("Error pulling in local Mimosa module: " + err);
    return process.exit(1);
  }
}).map(function(dep) {
  return {
    local: true,
    name: dep,
    nodeModulesDir: projectNodeModules
  };
}).value() : [];

locallyInstalledNames = _.pluck(locallyInstalled, 'name');

standardlyInstalled = _(mimosaPackage.dependencies).keys().select(function(dir) {
  return isMimosaModuleName(dir) && __indexOf.call(locallyInstalledNames, dir) < 0;
}).map(function(dep) {
  return {
    name: dep,
    nodeModulesDir: '../../node_modules'
  };
}).value();

independentlyInstalled = (function() {
  var standardlyResolvedModules, topLevelNodeModulesDir;
  topLevelNodeModulesDir = path.resolve(__dirname, '../../..');
  standardlyResolvedModules = _.pluck(standardlyInstalled, 'name');
  return _(fs.readdirSync(topLevelNodeModulesDir)).select(function(dir) {
    return isMimosaModuleName(dir) && __indexOf.call(standardlyResolvedModules, dir) < 0 && __indexOf.call(locallyInstalledNames, dir) < 0;
  }).map(function(dir) {
    return {
      name: dir,
      nodeModulesDir: topLevelNodeModulesDir
    };
  }).value();
})();

allInstalled = standardlyInstalled.concat(independentlyInstalled).concat(locallyInstalled);

meta = _.map(allInstalled, function(modInfo) {
  var err, modPack, requireString, resolvedPath;
  requireString = "" + modInfo.nodeModulesDir + "/" + modInfo.name + "/package.json";
  try {
    modPack = require(requireString);
    return {
      mod: modInfo.local ? require("" + modInfo.nodeModulesDir + "/" + modInfo.name + "/") : require(modInfo.name),
      name: modInfo.name,
      version: modPack.version,
      site: modPack.homepage,
      desc: modPack.description,
      "default": builtIns.indexOf(modInfo.name) > -1 ? "yes" : "no",
      dependencies: modPack.dependencies
    };
  } catch (_error) {
    err = _error;
    resolvedPath = path.resolve(requireString);
    logger.error("Unable to read file at [[ " + resolvedPath + " ]], possibly a permission issue? \nsystem error : " + err);
    return process.exit(1);
  }
});

metaNames = _.pluck(meta, 'name');

configModuleString = _.difference(metaNames, builtIns).length > 0 ? (names = metaNames.map(function(name) {
  return name.replace('mimosa-', '');
}), JSON.stringify(names)) : void 0;

configured = function(moduleNames, callback) {
  var index, processModule;
  if (configuredModules) {
    return configuredModules;
  }
  configuredModules = [file, compilers, logger];
  index = 0;
  processModule = function() {
    var found, fullModName, installString, installed, modName, modParts, modVersion, nodeModules, _i, _len,
      _this = this;
    if (index === moduleNames.length) {
      return callback(configuredModules);
    }
    modName = moduleNames[index++];
    if (modName.indexOf('mimosa-') !== 0) {
      modName = "mimosa-" + modName;
    }
    fullModName = modName;
    if (modName.indexOf('@') > 7) {
      modParts = modName.split('@');
      modName = modParts[0];
      modVersion = modParts[1];
    }
    found = false;
    for (_i = 0, _len = meta.length; _i < _len; _i++) {
      installed = meta[_i];
      if (installed.name === modName) {
        if (!((modVersion != null) && modVersion !== installed.version)) {
          found = true;
          installed.mod.__mimosaModuleName = modName;
          configuredModules.push(installed.mod);
          break;
        }
      }
    }
    if (found) {
      return processModule();
    } else {
      logger.info("Module [[ " + fullModName + " ]] cannot be found, attempting to install it from NPM into your project.");
      nodeModules = path.join(process.cwd(), "node_modules");
      if (!fs.existsSync(nodeModules)) {
        logger.info("node_modules directory does not exist, creating one...");
        fs.mkdirSync(nodeModules);
      }
      installString = "npm install " + fullModName;
      return exec(installString, function(err, sout, serr) {
        var modPath, requiredModule;
        if (err) {
          console.log("");
          logger.error("Unable to install [[ " + fullModName + " ]]\n");
          logger.info("Does the module exist in npm (https://npmjs.org/package/" + fullModName + ")?\n");
          logger.error(err);
          process.exit(1);
        } else {
          console.log(sout);
          logger.success("[[ " + fullModName + " ]] successfully installed into your project.");
          modPath = path.join(nodeModules, modName);
          Object.keys(require.cache).forEach(function(key) {
            if (key.indexOf(modPath) === 0) {
              return delete require.cache[key];
            }
          });
          try {
            requiredModule = require(modPath);
            requiredModule.__mimosaModuleName = modName;
            configuredModules.push(requiredModule);
          } catch (_error) {
            err = _error;
            logger.warn("There was an error attempting to include the newly installed module in the currently running Mimosa process," + " but the install was successful. Mimosa is exiting. When it is restarted, Mimosa will use the newly installed module.");
            logger.debug(err);
            process.exit(0);
          }
        }
        return processModule();
      });
    }
  };
  return processModule();
};

all = [compilers, logger, file, skels, newmod].concat(_.pluck(meta, 'mod'));

modulesWithCommands = function() {
  var mod, mods, _i, _len;
  mods = [];
  for (_i = 0, _len = all.length; _i < _len; _i++) {
    mod = all[_i];
    if (mod.registerCommand != null) {
      mods.push(mod);
    }
  }
  return mods;
};

module.exports = {
  installedMetadata: meta,
  getConfiguredModules: configured,
  all: all,
  configModuleString: configModuleString,
  modulesWithCommands: modulesWithCommands
};
