var NewCommand, buildConfig, compilers, deps, exec, fs, logger, moduleManager, path, servers, setupData, views, wrench, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

exec = require('child_process').exec;

fs = require('fs');

wrench = require('wrench');

_ = require('lodash');

logger = require('logmimosa');

deps = require('../../package.json').dependencies;

buildConfig = require('../util/config-builder');

moduleManager = require('../modules');

setupData = require("./setup.json");

compilers = setupData.compilers;

views = setupData.views;

servers = setupData.servers;

NewCommand = (function() {
  NewCommand.prototype.outConfig = {};

  NewCommand.prototype.devDependencies = {};

  function NewCommand(program) {
    this.program = program;
    this._done = __bind(this._done, this);
    this.removeFromPackageDeps = __bind(this.removeFromPackageDeps, this);
    this._modifyBowerJSONName = __bind(this._modifyBowerJSONName, this);
    this._makeServerChanges = __bind(this._makeServerChanges, this);
    this._create = __bind(this._create, this);
    this._createWithDefaults = __bind(this._createWithDefaults, this);
    this._prompting = __bind(this._prompting, this);
    this["new"] = __bind(this["new"], this);
    this.register = __bind(this.register, this);
  }

  NewCommand.prototype.register = function() {
    return this.program.command('new [name]').description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup").option("-d, --defaults", "bypass prompts and go with Mimosa defaults (CoffeeScript, Stylus, Handlebars)").option("-D, --mdebug", "run in debug mode").action(this["new"]).on('--help', this._printHelp);
  };

  NewCommand.prototype["new"] = function(name, opts) {
    var outPath;
    if (opts.mdebug) {
      opts.debug = true;
      logger.setDebug();
      process.env.DEBUG = true;
    }
    this.outConfig.modules = moduleManager.builtIns.map(function(builtIn) {
      return builtIn.substring(7);
    });
    logger.debug("Project name: " + name);
    this.skeletonOutPath = name ? (outPath = path.join(process.cwd(), name), fs.existsSync(outPath) ? (logger.error("Directory/file exists at [[ " + outPath + " ]], cannot continue."), process.exit(0)) : void 0, outPath) : process.cwd();
    if (opts.defaults) {
      return this._createWithDefaults(name);
    } else {
      return this._prompting(name);
    }
  };

  NewCommand.prototype._prompting = function(name) {
    var _this = this;
    if (logger.isDebug) {
      logger.debug("Compilers :\n" + (JSON.stringify(compilers, null, 2)));
    }
    logger.green("\n  Mimosa will guide you through technology selection and project creation. For");
    logger.green("  all of the selections, if your favorite is not an option, you can add a");
    logger.green("  GitHub issue and we'll look into adding it.");
    logger.green("\n  If you are unsure which options to pick, the ones with asterisks are Mimosa");
    logger.green("  favorites. Feel free to hit the web to research your selections, Mimosa will");
    logger.green("  be here when you get back.");
    logger.green("\n  To start, please choose your JavaScript meta-language: \n");
    return this.program.choose(_.pluck(compilers.javascript, 'prettyName'), function(i) {
      var chosen;
      logger.blue("\n  You chose " + compilers.javascript[i].prettyName + ".");
      chosen = {
        javascript: compilers.javascript[i]
      };
      logger.green("\n  Choose your CSS meta-language:\n");
      return _this.program.choose(_.pluck(compilers.css, 'prettyName'), function(i) {
        logger.blue("\n  You chose " + compilers.css[i].prettyName + ".");
        chosen.css = compilers.css[i];
        logger.green("\n  Choose your micro-templating language:\n");
        return _this.program.choose(_.pluck(compilers.template, 'prettyName'), function(i) {
          logger.blue("\n  You chose " + compilers.template[i].prettyName + ".");
          chosen.template = compilers.template[i];
          logger.green("\n  Choose your server technology: \n");
          return _this.program.choose(_.pluck(servers, 'prettyName'), function(i) {
            logger.blue("\n  You chose " + servers[i].prettyName + ".");
            chosen.server = servers[i];
            logger.green("\n  And finally choose your server view templating library:\n");
            return _this.program.choose(_.pluck(views, 'prettyName'), function(i) {
              logger.blue("\n  You chose " + views[i].prettyName + ".");
              chosen.views = views[i];
              logger.green("\n  Creating and setting up your project... \n");
              return _this._create(name, chosen);
            });
          });
        });
      });
    });
  };

  NewCommand.prototype._createWithDefaults = function(name) {
    var chosen;
    chosen = {};
    chosen.css = (compilers.css.filter(function(item) {
      return item.isDefault;
    }))[0];
    chosen.javascript = (compilers.javascript.filter(function(item) {
      return item.isDefault;
    }))[0];
    chosen.template = (compilers.template.filter(function(item) {
      return item.isDefault;
    }))[0];
    chosen.server = (servers.filter(function(item) {
      return item.isDefault;
    }))[0];
    chosen.views = (views.filter(function(item) {
      return item.isDefault;
    }))[0];
    if (logger.isDebug) {
      logger.debug("Chosen items :\n" + (JSON.stringify(chosen, null, 2)));
    }
    return this._create(name, chosen);
  };

  NewCommand.prototype._create = function(name, chosen) {
    var _this = this;
    [chosen.javascript.name, chosen.css.name, chosen.template.name].forEach(function(compName) {
      if (compName !== "none") {
        _this.outConfig.modules.push(compName);
        return _this.devDependencies["mimosa-" + compName] = "*";
      }
    });
    this.skeletonPath = path.join(__dirname, '..', '..', 'skeleton');
    this._moveDirectoryContents(this.skeletonPath, this.skeletonOutPath);
    this._makeChosenCompilerChanges(chosen);
    this._makeServerChanges(name, chosen);
    this._modifyBowerJSONName(name);
    this._moveViews(chosen);
    logger.debug("Renaming .gitignore");
    return fs.renameSync(path.join(this.skeletonOutPath, ".ignore"), path.join(this.skeletonOutPath, ".gitignore"));
  };

  NewCommand.prototype._makeServerChanges = function(name, chosen) {
    if (chosen.server.name === "None") {
      return this._usingNoServer();
    } else if (chosen.server.name === "Mimosa's Express") {
      return this._usingDefaultServer();
    } else {
      return this._usingOwnServer(name, chosen);
    }
  };

  NewCommand.prototype._modifyBowerJSONName = function(name) {
    var bowerJson, bowerPath;
    if (name) {
      bowerPath = path.join(this.skeletonOutPath, "bower.json");
      bowerJson = require(bowerPath);
      bowerJson.name = name;
      return fs.writeFileSync(bowerPath, JSON.stringify(bowerJson, null, 2));
    }
  };

  NewCommand.prototype._moveDirectoryContents = function(sourcePath, outPath) {
    var fileContents, fileStats, fullOutPath, fullSourcePath, item, _i, _len, _ref, _results;
    if (!fs.existsSync(outPath)) {
      fs.mkdirSync(outPath);
    }
    _ref = wrench.readdirSyncRecursive(sourcePath);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      fullSourcePath = path.join(sourcePath, item);
      fileStats = fs.statSync(fullSourcePath);
      fullOutPath = path.join(outPath, item);
      if (fileStats.isDirectory()) {
        logger.debug("Copying directory: [[ " + fullOutPath + " ]]");
        wrench.mkdirSyncRecursive(fullOutPath, 0x1ff);
      }
      if (fileStats.isFile()) {
        logger.debug("Copying file: [[ " + fullSourcePath + " ]]");
        fileContents = fs.readFileSync(fullSourcePath);
        _results.push(fs.writeFileSync(fullOutPath, fileContents));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  NewCommand.prototype._makeChosenCompilerChanges = function(chosenCompilers) {
    logger.debug("Chosen compilers:\n" + (JSON.stringify(chosenCompilers, null, 2)));
    this._updateConfigForChosenCompilers(chosenCompilers);
    return this._copyCompilerSpecificExampleFiles(chosenCompilers);
  };

  NewCommand.prototype._updateConfigForChosenCompilers = function(comps) {
    var _base, _base1, _base2;
    if (comps.javascript.isDefault && comps.views.isDefault) {
      return;
    }
    if (!comps.javascript.isDefault) {
      if ((_base = this.outConfig).server == null) {
        _base.server = {};
      }
      if (comps.javascript.name === "typescript") {
        this.outConfig.server.path = 'server.js';
      } else {
        this.outConfig.server.path = "server." + comps.javascript.defaultExtensions[0];
      }
    }
    if (!comps.views.isDefault) {
      if ((_base1 = this.outConfig).server == null) {
        _base1.server = {};
      }
      if ((_base2 = this.outConfig.server).views == null) {
        _base2.views = {};
      }
      this.outConfig.server.views.compileWith = comps.views.name;
      return this.outConfig.server.views.extension = comps.views.extension;
    }
  };

  NewCommand.prototype._copyCompilerSpecificExampleFiles = function(comps) {
    var allItems, assetsPath, baseIcedPath, cssFramework, data, file, filePath, files, isSafe, safePaths, serverPath, templateView, _i, _len;
    safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map(function(path) {
      return "\\." + path + "$";
    });
    assetsPath = path.join(this.skeletonOutPath, 'assets');
    allItems = wrench.readdirSyncRecursive(assetsPath);
    files = allItems.filter(function(i) {
      return fs.statSync(path.join(assetsPath, i)).isFile();
    });
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      filePath = path.join(assetsPath, file);
      isSafe = safePaths.some(function(path) {
        return file.match(path);
      });
      if (isSafe) {
        if (filePath.indexOf('example-view-') >= 0) {
          if (comps.template.defaultExtensions.some(function(ext) {
            return filePath.indexOf("-" + ext + ".") >= 0;
          })) {
            templateView = filePath;
          } else {
            isSafe = false;
          }
        }
        if (filePath.indexOf('handlebars-helpers') >= 0 && !comps.template.defaultExtensions.some(function(ext) {
          return ext === "hbs" || ext === "emblem";
        })) {
          isSafe = false;
        }
      }
      if (!isSafe) {
        fs.unlinkSync(filePath);
      }
    }
    serverPath = path.join(this.skeletonOutPath, 'servers');
    allItems = wrench.readdirSyncRecursive(serverPath);
    files = allItems.filter(function(i) {
      return fs.statSync(path.join(serverPath, i)).isFile();
    });
    if (comps.javascript.name === "typescript") {
      safePaths.push("\\.js$");
    }
    files.filter(function(file) {
      return !safePaths.some(function(pathh) {
        return file.match(pathh);
      });
    }).map(function(file) {
      return path.join(serverPath, file);
    }).forEach(function(filePath) {
      return fs.unlinkSync(filePath);
    });
    if (comps.javascript.name === "iced-coffeescript") {
      baseIcedPath = path.join(this.skeletonOutPath, "assets", "javascripts", "vendor");
      fs.renameSync(path.join(baseIcedPath, "iced.js.iced"), path.join(baseIcedPath, "iced.js"));
    }
    if (templateView != null) {
      data = fs.readFileSync(templateView, "ascii");
      fs.unlinkSync(templateView);
      cssFramework = comps.css.name === "none" ? "pure CSS" : comps.css.name;
      data = data.replace("CSSHERE", cssFramework);
      templateView = templateView.replace(/-\w+\./, ".");
      return fs.writeFile(templateView, data);
    }
  };

  NewCommand.prototype._moveViews = function(chosen) {
    logger.debug("Moving views into place");
    this._moveDirectoryContents(path.join(this.skeletonOutPath, "view", chosen.views.name), this.skeletonOutPath);
    return wrench.rmdirSyncRecursive(path.join(this.skeletonOutPath, "view"));
  };

  NewCommand.prototype._usingNoServer = function() {
    logger.debug("Using no server, so removing server resources and config");
    fs.unlinkSync(path.join(this.skeletonOutPath, "package.json"));
    wrench.rmdirSyncRecursive(path.join(this.skeletonOutPath, "servers"));
    return this._done();
  };

  NewCommand.prototype._usingDefaultServer = function() {
    var _base;
    logger.debug("Using default server, so removing server resources");
    fs.unlinkSync(path.join(this.skeletonOutPath, "package.json"));
    wrench.rmdirSyncRecursive(path.join(this.skeletonOutPath, "servers"));
    if ((_base = this.outConfig).server == null) {
      _base.server = {};
    }
    this.outConfig.server.defaultServer = {
      enabled: true
    };
    return this._done();
  };

  NewCommand.prototype._usingOwnServer = function(name, chosen) {
    var currentDir, jPath, packageJson,
      _this = this;
    logger.debug("Making package.json edits");
    jPath = path.join(this.skeletonOutPath, "package.json");
    packageJson = require(jPath);
    if (name != null) {
      packageJson.name = name;
    }
    if (Object.keys(this.devDependencies).length > 0) {
      packageJson.devDependencies = this.devDependencies;
    }
    this.removeFromPackageDeps(chosen.javascript.name, "livescript", "LiveScript", packageJson);
    this.removeFromPackageDeps(chosen.javascript.name, "iced-coffeescript", "iced-coffee-script", packageJson);
    this.removeFromPackageDeps(chosen.javascript.name, "coffeescript", "coffee-script", packageJson);
    this.removeFromPackageDeps(chosen.javascript.name, "coco", "coco", packageJson);
    this.removeFromPackageDeps(chosen.views.name, "jade", "jade", packageJson);
    this.removeFromPackageDeps(chosen.views.name, "hogan", "hogan.js", packageJson);
    this.removeFromPackageDeps(chosen.views.name, "dust", "dustjs-linkedin", packageJson);
    this.removeFromPackageDeps(chosen.views.name, "handlebars", "handlebars", packageJson);
    if (chosen.views.library !== "ejs") {
      this.removeFromPackageDeps(chosen.views.name, "html", "ejs", packageJson);
      this.removeFromPackageDeps(chosen.views.name, "ejs", "ejs", packageJson);
    }
    fs.writeFileSync(jPath, JSON.stringify(packageJson, null, 2));
    logger.debug("Moving server into place");
    this.removeFromPackageDeps(chosen.server.name.toLowerCase(), "express", "express", packageJson);
    this._moveDirectoryContents(path.join(this.skeletonOutPath, "servers", chosen.server.name.toLowerCase()), this.skeletonOutPath);
    wrench.rmdirSyncRecursive(path.join(this.skeletonOutPath, "servers"));
    logger.info("Installing node modules");
    currentDir = process.cwd();
    process.chdir(this.skeletonOutPath);
    return exec("npm install", function(err, sout, serr) {
      if (err) {
        logger.error(err);
      } else {
        console.log(sout);
      }
      logger.debug("Node module install sout: " + sout);
      logger.debug("Node module install serr: " + serr);
      process.chdir(currentDir);
      return _this._done();
    });
  };

  NewCommand.prototype.removeFromPackageDeps = function(item, match, lib, json) {
    if (item !== match) {
      logger.debug("removing " + lib + " from package.json");
      return delete json.dependencies[lib];
    }
  };

  NewCommand.prototype._done = function() {
    var configPath, outConfigText,
      _this = this;
    configPath = path.join(this.skeletonOutPath, "mimosa-config.js");
    outConfigText = "exports.config = " + JSON.stringify(this.outConfig, null, 2);
    return fs.writeFile(configPath, outConfigText, function(err) {
      var currentDir;
      currentDir = process.cwd();
      process.chdir(_this.skeletonOutPath);
      return exec("mimosa config --suppress", function(err, sout, serr) {
        if (err) {
          logger.error(err);
        } else {
          console.log(sout);
        }
        process.chdir(currentDir);
        logger.success("New project creation complete!  Execute 'mimosa watch' from inside your project to monitor the file system. Then start coding!");
        return process.stdin.destroy();
      });
    });
  };

  NewCommand.prototype._printHelp = function() {
    logger.green('  The new command will take you through a series of questions regarding what');
    logger.green('  JavaScript meta-language, CSS meta-language, micro-templating library, server');
    logger.green('  and server view technology you would like to use to build your project. Once');
    logger.green('  you have answered the questions, Mimosa will create a directory using the name');
    logger.green('  you provided, and place a project skeleton inside of it.  That project skeleton');
    logger.green('  will by default include a basic application using the technologies you selected.');
    logger.blue('\n    $ mimosa new [nameOfProject]\n');
    logger.green('  If you wish to copy the project skeleton into your current directory instead of');
    logger.green('  into a new one leave off the name.');
    logger.blue('\n    $ mimosa new\n');
    logger.green('  If you are happy with the defaults (CoffeeScript, Stylus, Handlebars, Express, Jade),');
    logger.green('  you can bypass the prompts by providing a \'defaults\' flag.');
    logger.blue('\n    $ mimosa new [name] --defaults');
    return logger.blue('    $ mimosa new [name] -d\n');
  };

  return NewCommand;

})();

module.exports = function(program) {
  var command;
  command = new NewCommand(program);
  return command.register();
};
