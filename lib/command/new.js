var NewCommand, buildConfig, compilerCentral, deps, exec, fs, logger, path, wrench, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

exec = require('child_process').exec;

fs = require('fs');

wrench = require('wrench');

_ = require('lodash');

logger = require('logmimosa');

compilerCentral = require('../modules/compilers');

deps = require('../../package.json').dependencies;

buildConfig = require('../util/config-builder');

NewCommand = (function() {
  NewCommand.prototype.servers = [
    {
      name: "none",
      prettyName: "None - You don't need a server, or you'd like Mimosa to serve your application for you."
    }, {
      name: "express",
      prettyName: "(*) Express - http://expressjs.com/",
      isDefault: true
    }
  ];

  NewCommand.prototype.views = [
    {
      name: "jade",
      prettyName: "(*) Jade - http://jade-lang.com/",
      library: "jade",
      extension: "jade",
      isDefault: true
    }, {
      name: "hogan",
      prettyName: "Hogan - http://twitter.github.com/hogan.js/",
      library: "hogan.js",
      extension: "hjs"
    }, {
      name: "html",
      prettyName: "Plain HTML",
      library: "ejs",
      extension: "html"
    }, {
      name: "ejs",
      prettyName: "Embedded JavaScript Templates (EJS) - https://github.com/visionmedia/ejs",
      library: "ejs",
      extension: "ejs"
    }, {
      name: "handlebars",
      prettyName: "Handlebars - http://handlebarsjs.com/",
      library: "handlebars",
      extension: "hbs"
    }, {
      name: "dust",
      prettyName: "Dust - http://linkedin.github.io/dustjs/",
      library: "dustjs-linkedin",
      extension: "dust"
    }
  ];

  function NewCommand(program) {
    this.program = program;
    this._done = __bind(this._done, this);
    this.removeFromPackageDeps = __bind(this.removeFromPackageDeps, this);
    this._create = __bind(this._create, this);
    this._createWithDefaults = __bind(this._createWithDefaults, this);
    this._prompting = __bind(this._prompting, this);
    this["new"] = __bind(this["new"], this);
    this.register = __bind(this.register, this);
  }

  NewCommand.prototype.register = function() {
    return this.program.command('new [name]').description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup").option("-d, --defaults", "bypass prompts and go with Mimosa defaults (CoffeeScript, Stylus, Handlebars)").option("-D, --debug", "run in debug mode").action(this["new"]).on('--help', this._printHelp);
  };

  NewCommand.prototype["new"] = function(name, opts) {
    var compilers, outPath;
    if (opts.debug) {
      logger.setDebug();
      process.env.DEBUG = true;
    }
    logger.debug("Project name: " + name);
    this.skeletonOutPath = name ? (outPath = path.join(process.cwd(), name), fs.existsSync(outPath) ? (logger.error("Directory/file exists at [[ " + outPath + " ]], cannot continue."), process.exit(0)) : void 0, outPath) : process.cwd();
    compilers = compilerCentral.compilersByType();
    if (opts.defaults) {
      return this._createWithDefaults(compilers, name);
    } else {
      return this._prompting(compilers, name);
    }
  };

  NewCommand.prototype._prompting = function(compilers, name) {
    var _this = this;
    logger.debug("Compilers :\n" + (JSON.stringify(compilers, null, 2)));
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
          logger.green("\n  Choose your server technology, if you pick no server, Mimosa will serve your assets for you:\n");
          return _this.program.choose(_.pluck(_this.servers, 'prettyName'), function(i) {
            logger.blue("\n  You chose " + _this.servers[i].prettyName + ".");
            chosen.server = _this.servers[i];
            logger.green("\n  And finally choose your server view templating library:\n");
            return _this.program.choose(_.pluck(_this.views, 'prettyName'), function(i) {
              logger.blue("\n  You chose " + _this.views[i].prettyName + ".");
              chosen.views = _this.views[i];
              logger.green("\n  Creating and setting up your project... \n");
              return _this._create(name, chosen);
            });
          });
        });
      });
    });
  };

  NewCommand.prototype._createWithDefaults = function(compilers, name) {
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
    chosen.server = (this.servers.filter(function(item) {
      return item.isDefault;
    }))[0];
    chosen.views = (this.views.filter(function(item) {
      return item.isDefault;
    }))[0];
    return this._create(name, chosen);
  };

  NewCommand.prototype._create = function(name, chosen) {
    this.config = buildConfig();
    this.skeletonPath = path.join(__dirname, '..', '..', 'skeletons', 'project');
    this._moveDirectoryContents(this.skeletonPath, this.skeletonOutPath);
    this._makeChosenCompilerChanges(chosen);
    if (chosen.server.name === "none") {
      this._usingDefaultServer();
    } else {
      this._usingOwnServer(name, chosen);
    }
    this._moveViews(chosen);
    logger.debug("Renaming .gitignore");
    return fs.renameSync(path.join(this.skeletonOutPath, ".ignore"), path.join(this.skeletonOutPath, ".gitignore"));
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
    var replacements, that, thiz, _results;
    if (comps.javascript.isDefault && comps.views.isDefault) {
      return;
    }
    replacements = {};
    if (!comps.javascript.isDefault) {
      replacements["# server:"] = "server:";
      if (comps.javascript.base === "typescript") {
        replacements["# path: 'server.coffee'"] = "path: 'server.js'";
      } else {
        replacements["# path: 'server.coffee'"] = "path: 'server." + comps.javascript.defaultExtensions[0] + "'";
      }
    }
    if (!comps.views.isDefault) {
      replacements["# server:"] = "server:";
      replacements["# views:"] = "views:";
      replacements["# compileWith: 'jade'"] = "compileWith: '" + comps.views.name + "'";
      replacements["# extension: 'jade'"] = "extension: '" + comps.views.extension + "'";
    }
    _results = [];
    for (thiz in replacements) {
      that = replacements[thiz];
      _results.push(this.config = this.config.replace(thiz, that));
    }
    return _results;
  };

  NewCommand.prototype._copyCompilerSpecificExampleFiles = function(comps) {
    var allItems, assetsPath, baseIcedPath, cssFramework, data, file, filePath, files, isSafe, safePaths, serverPath, templateView, _i, _len;
    safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map(function(path) {
      return "\\." + path + "$";
    });
    safePaths.push("jquery\.js");
    safePaths.push("require\.js");
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
    if (comps.javascript.base === "typescript") {
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
    if (comps.javascript.base === "iced") {
      baseIcedPath = path.join(this.skeletonOutPath, "assets", "javascripts", "vendor");
      fs.renameSync(path.join(baseIcedPath, "iced.js.iced"), path.join(baseIcedPath, "iced.js"));
    }
    if (templateView != null) {
      data = fs.readFileSync(templateView, "ascii");
      fs.unlinkSync(templateView);
      cssFramework = comps.css.base === "none" ? "pure CSS" : comps.css.base;
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

  NewCommand.prototype._usingDefaultServer = function() {
    logger.debug("Using default server, so removing server resources");
    fs.unlinkSync(path.join(this.skeletonOutPath, "package.json"));
    wrench.rmdirSyncRecursive(path.join(this.skeletonOutPath, "servers"));
    this.config = this.config.replace("# server:", "server:");
    this.config = this.config.replace("# defaultServer:", "defaultServer:");
    this.config = this.config.replace("# enabled: false           # whether", "enabled: true              # whether");
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
    this.removeFromPackageDeps(chosen.javascript.base, "livescript", "LiveScript", packageJson);
    this.removeFromPackageDeps(chosen.javascript.base, "iced", "iced-coffee-script", packageJson);
    this.removeFromPackageDeps(chosen.javascript.base, "coffee", "coffee-script", packageJson);
    this.removeFromPackageDeps(chosen.javascript.base, "coco", "coco", packageJson);
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
    this._moveDirectoryContents(path.join(this.skeletonOutPath, "servers", chosen.server.name), this.skeletonOutPath);
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
    var configPath;
    configPath = path.join(this.skeletonOutPath, "mimosa-config.coffee");
    return fs.writeFile(configPath, this.config, function(err) {
      logger.success("New project creation complete!  Execute 'mimosa watch --server' from inside your project to monitor the file system. Then start coding!");
      return process.stdin.destroy();
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
