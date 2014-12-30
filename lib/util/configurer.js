"use strict";
var Module, PRECOMPILE_FUN_REGION_END_RE, PRECOMPILE_FUN_REGION_LINES_MAX, PRECOMPILE_FUN_REGION_SEARCH_LINES_MAX, PRECOMPILE_FUN_REGION_START_RE, baseDefaults, coffeescript, fileUtils, fs, logger, moduleManager, path, processConfig, validators, wrench, _, _applyAndValidateDefaults, _extend, _extractPrecompileFunctionSource, _findConfigPath, _moduleDefaults, _requireConfig, _setModulesIntoConfig, _setUpHelpers, _validateSettings, _validateWatchConfig;

path = require('path');

fs = require('fs');

wrench = require('wrench');

logger = require('logmimosa');

_ = require('lodash');

coffeescript = require('coffee-script');

validators = require('validatemimosa');

moduleManager = require('../modules');

Module = require('module');

fileUtils = require('../util/file');

PRECOMPILE_FUN_REGION_START_RE = /^(.*)\smimosa-config:\s*{/;

PRECOMPILE_FUN_REGION_END_RE = /\smimosa-config:\s*}/;

PRECOMPILE_FUN_REGION_SEARCH_LINES_MAX = 5;

PRECOMPILE_FUN_REGION_LINES_MAX = 100;

baseDefaults = {
  minMimosaVersion: null,
  requiredMimosaVersion: null,
  modules: ['copy', 'jshint', 'csslint', 'server', 'require', 'minify-js', 'minify-css', 'live-reload', 'bower'],
  resortCompilers: true,
  timer: {
    enabled: false
  },
  watch: {
    sourceDir: "assets",
    compiledDir: "public",
    javascriptDir: "javascripts",
    exclude: [/[/\\](\.|~)[^/\\]+$/],
    throttle: 0,
    interval: 100,
    binaryInterval: 300,
    usePolling: true,
    delay: 0
  },
  vendor: {
    javascripts: "javascripts/vendor",
    stylesheets: "stylesheets/vendor"
  }
};

_extend = function(obj, props, resetObjAndRetry) {
  Object.keys(props).forEach(function(k) {
    var val;
    val = props[k];
    if ((val != null) && (typeof val === 'object') && (!Array.isArray(val)) && (!(val instanceof RegExp))) {
      if (obj === null) {
        return resetObjAndRetry();
      } else {
        if (typeof obj[k] === typeof val) {
          return _extend(obj[k], val, function() {
            obj[k] = {};
            return _extend(obj[k], val);
          });
        } else {
          return obj[k] = val;
        }
      }
    } else {
      return obj[k] = val;
    }
  });
  return obj;
};

_findConfigPath = function(file) {
  var configPath, ext, _i, _len, _ref;
  _ref = [".coffee", ".js", ""];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    ext = _ref[_i];
    configPath = path.resolve("" + file + ext);
    if (fs.existsSync(configPath)) {
      return configPath;
    }
  }
};

_validateWatchConfig = function(config) {
  var currVersion, errors, i, isHigher, js, jsDir, minVersionPieces, msg, piece, ss, vPiece, versionPieces, _i, _ref, _ref1;
  errors = [];
  if ((config.minMimosaVersion != null) && (config.requiredMimosaVersion != null)) {
    return ["Cannot have both minMimosaVersion and requiredMimosaVersion"];
  }
  if (config.minMimosaVersion != null) {
    if (config.minMimosaVersion.match(/^(\d+\.){2}(\d+)$/)) {
      currVersion = require('../../package.json').version;
      versionPieces = currVersion.split('.');
      minVersionPieces = config.minMimosaVersion.split('.');
      isHigher = false;
      for (i = _i = 0; _i <= 2; i = ++_i) {
        piece = minVersionPieces[i].split('-')[0];
        vPiece = versionPieces[i].split('-')[0];
        if (+vPiece > +piece) {
          isHigher = true;
        }
        if (!isHigher) {
          if (+vPiece < +piece) {
            return ["Your version of Mimosa [[ " + currVersion + " ]] is less than the required minimum version for this project [[ " + config.minMimosaVersion + " ]]"];
          }
        }
      }
    } else {
      errors.push("minMimosaVersion must take the form 'number.number.number', ex: '1.1.0'");
    }
  }
  if (config.requiredMimosaVersion != null) {
    if (config.requiredMimosaVersion.match(/^(\d+\.){2}(\d+)$/)) {
      currVersion = require('../../package.json').version;
      if (currVersion !== config.requiredMimosaVersion) {
        return ["Your version of Mimosa [[ " + currVersion + " ]] does not match the required version for this project [[ " + config.requiredMimosaVersion + " ]]"];
      }
    } else {
      errors.push("requiredMimosaVersion must take the form 'number.number.number', ex: '1.1.0'");
    }
  }
  config.watch.sourceDir = validators.multiPathMustExist(errors, "watch.sourceDir", config.watch.sourceDir, config.root);
  if (errors.length > 0) {
    return errors;
  }
  if (typeof config.watch.compiledDir === "string") {
    config.watch.compiledDir = validators.determinePath(config.watch.compiledDir, config.root);
    if (!fs.existsSync(config.watch.compiledDir) && !config.isForceClean) {
      if (((_ref = config.logger) != null ? _ref.info : void 0) != null) {
        if (config.logger.info.enabled) {
          logger.info("Did not find compiled directory [[ " + config.watch.compiledDir + " ]], so making it for you");
        }
      } else {
        logger.info("Did not find compiled directory [[ " + config.watch.compiledDir + " ]], so making it for you");
      }
      wrench.mkdirSyncRecursive(config.watch.compiledDir, 0x1ff);
    }
  } else {
    errors.push("watch.compiledDir must be a string");
  }
  if (typeof config.watch.javascriptDir === "string") {
    jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir);
    validators.doesPathExist(errors, "watch.javascriptDir", jsDir);
  } else {
    if (config.watch.javascriptDir === null) {
      config.watch.javascriptDir = "";
    } else {
      errors.push("watch.javascriptDir must be a string or null");
    }
  }
  validators.ifExistsFileExcludeWithRegexAndString(errors, "watch.exclude", config.watch, config.watch.sourceDir);
  if (typeof config.watch.throttle !== "number") {
    errors.push("watch.throttle must be a number");
  }
  if (typeof config.watch.interval !== "number") {
    errors.push("watch.interval must be a number");
  }
  if (typeof config.watch.binaryInterval !== "number") {
    errors.push("watch.binaryInterval must be a number");
  }
  if (validators.ifExistsIsBoolean(errors, "watch.usePolling", config.watch.usePolling)) {
    if (process.platform !== 'win32' && config.watch.usePolling === false) {
      msg = "You have turned polling off (usePolling:false) but you are on not on Windows. If you\nexperience EMFILE issues, this is why. usePolling:false does not function properly on\nother operating systems.";
      if (((_ref1 = config.logger) != null ? _ref1.warn : void 0) != null) {
        if (config.logger.warn.enabled) {
          logger.info(msg);
        }
      } else {
        logger.info(msg);
      }
    }
  }
  if (validators.ifExistsIsObject(errors, "vendor config", config.vendor)) {
    if (validators.ifExistsIsString(errors, "vendor.javascripts", config.vendor.javascripts)) {
      js = config.vendor.javascripts.split('/').join(path.sep);
      config.vendor.javascripts = path.join(config.watch.sourceDir, js);
    }
    if (validators.ifExistsIsString(errors, "vendor.stylesheets", config.vendor.stylesheets)) {
      ss = config.vendor.stylesheets.split('/').join(path.sep);
      config.vendor.stylesheets = path.join(config.watch.sourceDir, ss);
    }
  }
  return errors;
};

_requireConfig = function(configPath) {
  var config, configModule, err, extname, precompileFunSource, raw;
  extname = path.extname(configPath);
  if (extname) {
    if (extname === ".coffee") {
      coffeescript.register();
    }
    return require(configPath);
  } else {
    raw = fs.readFileSync(configPath, "utf8");
    config = raw.charCodeAt(0) === 0xFEFF ? raw.substring(1) : raw;
    precompileFunSource = _extractPrecompileFunctionSource(config);
    if (precompileFunSource.length > 0) {
      try {
        config = eval("(" + (precompileFunSource.replace(/;\s*$/, '')) + ")")(config);
      } catch (_error) {
        err = _error;
        if (err instanceof SyntaxError) {
          err.message = "[precompile region] " + err.message;
        }
        throw err;
      }
    }
    configModule = new Module(path.resolve(configPath));
    configModule.filename = configModule.id;
    configModule.paths = Module._nodeModulePaths(path.dirname(configModule.id));
    configModule._compile(config, configPath);
    configModule.loaded = true;
    return configModule.exports;
  }
};

_extractPrecompileFunctionSource = function(configSource) {
  var configLinesRead, functionRegionLinesRead, functionSource, markerLinePrefix, newlinePos, pos, sourceLine, _ref;
  pos = configLinesRead = functionRegionLinesRead = 0;
  while ((pos < configSource.length) && (functionRegionLinesRead ? functionRegionLinesRead < PRECOMPILE_FUN_REGION_LINES_MAX : configLinesRead < PRECOMPILE_FUN_REGION_SEARCH_LINES_MAX)) {
    newlinePos = configSource.indexOf("\n", pos);
    if (newlinePos === -1) {
      newlinePos = configSource.length;
    }
    sourceLine = configSource.substr(pos, newlinePos - pos);
    pos = newlinePos + 1;
    if (!functionRegionLinesRead) {
      if (markerLinePrefix = (_ref = PRECOMPILE_FUN_REGION_START_RE.exec(sourceLine)) != null ? _ref[1] : void 0) {
        functionRegionLinesRead = 1;
        functionSource = "";
      } else {
        configLinesRead++;
      }
    } else {
      if (PRECOMPILE_FUN_REGION_END_RE.test(sourceLine)) {
        return functionSource;
      }
      functionRegionLinesRead++;
      functionSource += "" + (sourceLine.replace(markerLinePrefix, '')) + "\n";
    }
  }
  return "";
};

_setUpHelpers = function(config) {
  config.helpers = {
    file: {
      write: fileUtils.writeFile
    }
  };
  return config.log = logger;
};

_validateSettings = function(config, modules) {
  var currentlyNeedsClean, errors, mod, moduleErrors, _i, _len;
  errors = _validateWatchConfig(config);
  if (errors.length === 0) {
    config.extensions = {
      javascript: ['js'],
      css: ['css'],
      template: [],
      copy: [],
      misc: []
    };
    config.watch.compiledJavascriptDir = validators.determinePath(config.watch.javascriptDir, config.watch.compiledDir);
  } else {
    return [errors, {}];
  }
  currentlyNeedsClean = false;
  for (_i = 0, _len = modules.length; _i < _len; _i++) {
    mod = modules[_i];
    if (mod.validate == null) {
      continue;
    }
    moduleErrors = mod.validate(config, validators);
    if ((moduleErrors != null) && Array.isArray(moduleErrors) && moduleErrors.length) {
      errors.push.apply(errors, moduleErrors);
    } else {
      if (!currentlyNeedsClean && config.needsClean) {
        currentlyNeedsClean = true;
        logger.debug("The " + mod.__mimosaModuleName + " module has requested a clean be performed before building the application");
      }
    }
  }
  return [errors, config];
};

_moduleDefaults = function(modules) {
  var defs, mod, _i, _len;
  defs = {};
  for (_i = 0, _len = modules.length; _i < _len; _i++) {
    mod = modules[_i];
    if (mod.defaults != null) {
      _.extend(defs, mod.defaults());
    }
  }
  _.extend(defs, baseDefaults);
  return defs;
};

_applyAndValidateDefaults = function(config, callback) {
  var moduleNames, _ref;
  moduleNames = (_ref = config.modules) != null ? _ref : baseDefaults.modules;
  return moduleManager.getConfiguredModules(moduleNames, function(modules) {
    var err, errors, _ref1;
    config.root = process.cwd();
    config = _extend(_moduleDefaults(modules), config);
    _setUpHelpers(config);
    _ref1 = _validateSettings(config, modules), errors = _ref1[0], config = _ref1[1];
    err = errors.length === 0 ? (logger.debug("No mimosa config errors"), null) : errors;
    return callback(err, config, modules);
  });
};

processConfig = function(opts, callback) {
  var config, defaultProfileLocation, defaultProfileText, defaultProfiles, err, mainConfigPath;
  config = {};
  mainConfigPath = _findConfigPath("mimosa-config");
  if (mainConfigPath != null) {
    try {
      config = _requireConfig(mainConfigPath).config;
    } catch (_error) {
      err = _error;
      return logger.fatal("Improperly formatted configuration file [[ " + mainConfigPath + " ]]: " + err);
    }
  } else {
    logger.warn("No configuration file found (mimosa-config.coffee/mimosa-config.js/mimosa-config), running from current directory using Mimosa's defaults.");
    logger.warn("Run 'mimosa config' to copy the default Mimosa configuration to the current directory.");
  }
  defaultProfileLocation = path.join(process.cwd(), ".mimosa_profile");
  if (fs.existsSync(defaultProfileLocation)) {
    defaultProfileText = fs.readFileSync(defaultProfileLocation, "utf8");
    if (defaultProfileText.trim().length > 0) {
      defaultProfiles = defaultProfileText.split("\n");
      if (opts.profile) {
        opts.profile = [defaultProfiles, opts.profile].join('#');
      } else {
        opts.profile = defaultProfiles.join("#");
      }
    }
  }
  if (opts.profile) {
    logger.info("Applying build profiles:", opts.profile.split("#").join(", "));
    if (!config.profileLocation) {
      config.profileLocation = "profiles";
    }
    opts.profile.split("#").forEach(function(profileName) {
      var profileConfig, profileConfigPath;
      profileConfigPath = _findConfigPath(path.join(config.profileLocation, profileName));
      if (profileConfigPath != null) {
        try {
          profileConfig = _requireConfig(profileConfigPath).config;
        } catch (_error) {
          err = _error;
          return logger.fatal("Improperly formatted configuration file [[ " + profileConfigPath + " ]]: " + err);
        }
        if (logger.isDebug()) {
          logger.debug("Profile config:\n" + (JSON.stringify(profileConfig, null, 2)));
        }
        config = _extend(config, profileConfig);
        if (logger.isDebug()) {
          return logger.debug("mimosa config after profile applied:\n" + (JSON.stringify(config, null, 2)));
        }
      } else {
        return logger.fatal("Profile provided but not found at [[ " + (path.join('profiles', profileName)) + " ]]");
      }
    });
  }
  config.isServer = opts != null ? opts.server : void 0;
  config.isOptimize = opts != null ? opts.optimize : void 0;
  config.isMinify = opts != null ? opts.minify : void 0;
  config.isForceClean = opts != null ? opts.force : void 0;
  config.isClean = opts != null ? opts.clean : void 0;
  config.isBuild = opts != null ? opts.build : void 0;
  config.isWatch = opts != null ? opts.watch : void 0;
  config.isPackage = opts != null ? opts["package"] : void 0;
  config.isInstall = opts != null ? opts.install : void 0;
  config.exitOnError = opts != null ? opts.errorout : void 0;
  return _applyAndValidateDefaults(config, function(err, newConfig, modules) {
    var util;
    if (err) {
      logger.error("Unable to start Mimosa for the following reason(s):\n * " + (err.join('\n * ')) + " ");
      return process.exit(1);
    } else {
      _setModulesIntoConfig(newConfig);
      logger.setConfig(newConfig);
      if (logger.isDebug()) {
        util = require('util');
        logger.debug("******************");
        logger.debug("Your mimosa config:\n" + (JSON.stringify(config, null, 2)));
        logger.debug("******************");
        logger.debug("Full mimosa config:\n" + (util.inspect(newConfig)));
        logger.debug("******************");
      }
      return callback(newConfig, modules);
    }
  });
};

_setModulesIntoConfig = function(config) {
  config.installedModules = {};
  return moduleManager.getConfiguredModules().forEach(function(mod) {
    return config.installedModules[mod.__mimosaModuleName] = mod;
  });
};

module.exports = processConfig;
