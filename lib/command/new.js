var buildConfig, compilers, copyCompilerSpecificExampleFiles, create, createWithDefaults, deps, devDependencies, exec, fs, logger, makeChosenCompilerChanges, makeServerChanges, modifyBowerJSONName, moduleManager, moveDirectoryContents, moveViews, newProject, outConfig, packageJson, path, printHelp, program, projectName, prompting, register, runNPMInstall, servers, setupData, setupPackageJSON, skeletonOutPath, updateConfigForChosenCompilers, usingDefaultServer, usingNoServer, usingOwnServer, views, wrench, writeConfigs, _;

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

program = null;

projectName = null;

outConfig = {};

devDependencies = {};

packageJson = null;

skeletonOutPath = process.cwd();

printHelp = function() {
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

moveDirectoryContents = function(sourcePath, outPath) {
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

create = function(chosen) {
  var skeletonPath;
  [chosen.javascript.name, chosen.css.name, chosen.template.name].forEach(function(compName) {
    if (compName !== "none") {
      outConfig.modules.push(compName);
      return devDependencies["mimosa-" + compName] = "*";
    }
  });
  skeletonPath = path.join(__dirname, '..', '..', 'skeleton');
  moveDirectoryContents(skeletonPath, skeletonOutPath);
  setupPackageJSON(chosen);
  makeChosenCompilerChanges(chosen);
  modifyBowerJSONName();
  moveViews(chosen);
  makeServerChanges(chosen);
  runNPMInstall();
  logger.debug("Renaming .gitignore");
  return fs.renameSync(path.join(skeletonOutPath, ".ignore"), path.join(skeletonOutPath, ".gitignore"));
};

createWithDefaults = function() {
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
  return create(chosen);
};

updateConfigForChosenCompilers = function(comps) {
  var _base;
  if (comps.javascript.isDefault && comps.views.isDefault) {
    return;
  }
  if ((!comps.javascript.isDefault) && (comps.server.name !== "None")) {
    if (outConfig.server == null) {
      outConfig.server = {};
    }
    if (comps.javascript.name === "typescript") {
      outConfig.server.path = 'server.js';
    } else {
      outConfig.server.path = "server." + comps.javascript.defaultExtensions[0];
    }
  }
  if (!comps.views.isDefault) {
    if (outConfig.server == null) {
      outConfig.server = {};
    }
    if ((_base = outConfig.server).views == null) {
      _base.views = {};
    }
    outConfig.server.views.compileWith = comps.views.name;
    return outConfig.server.views.extension = comps.views.extension;
  }
};

makeChosenCompilerChanges = function(chosenCompilers) {
  logger.debug("Chosen compilers:\n" + (JSON.stringify(chosenCompilers, null, 2)));
  updateConfigForChosenCompilers(chosenCompilers);
  return copyCompilerSpecificExampleFiles(chosenCompilers);
};

usingOwnServer = function(chosen) {
  logger.debug("Moving server into place");
  moveDirectoryContents(path.join(skeletonOutPath, "servers", chosen.server.name.toLowerCase()), skeletonOutPath);
  return wrench.rmdirSyncRecursive(path.join(skeletonOutPath, "servers"));
};

modifyBowerJSONName = function() {
  var bowerJson, bowerPath;
  if (projectName) {
    bowerPath = path.join(skeletonOutPath, "bower.json");
    bowerJson = require(bowerPath);
    bowerJson.name = projectName;
    return fs.writeFileSync(bowerPath, JSON.stringify(bowerJson, null, 2));
  }
};

copyCompilerSpecificExampleFiles = function(comps) {
  var allItems, assetsPath, baseIcedPath, cssFramework, data, file, filePath, files, isSafe, safePaths, serverPath, templateView, _i, _len;
  safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map(function(path) {
    return "\\." + path + "$";
  });
  assetsPath = path.join(skeletonOutPath, 'assets');
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
  serverPath = path.join(skeletonOutPath, 'servers');
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
    baseIcedPath = path.join(skeletonOutPath, "assets", "javascripts", "vendor");
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

moveViews = function(chosen) {
  logger.debug("Moving views into place");
  moveDirectoryContents(path.join(skeletonOutPath, "view", chosen.views.name), skeletonOutPath);
  return wrench.rmdirSyncRecursive(path.join(skeletonOutPath, "view"));
};

usingNoServer = function() {
  outConfig.modules.splice(outConfig.modules.indexOf("server"), 1);
  outConfig.modules.splice(outConfig.modules.indexOf("live-reload"), 1);
  logger.debug("Using no server, so removing server resources and config");
  return wrench.rmdirSyncRecursive(path.join(skeletonOutPath, "servers"));
};

usingDefaultServer = function() {
  logger.debug("Using default server, so removing server resources");
  wrench.rmdirSyncRecursive(path.join(skeletonOutPath, "servers"));
  if (outConfig.server == null) {
    outConfig.server = {};
  }
  return outConfig.server.defaultServer = {
    enabled: true
  };
};

makeServerChanges = function(chosen) {
  if (chosen.server.name === "None") {
    return usingNoServer();
  } else if (chosen.server.name === "Mimosa's Express") {
    return usingDefaultServer();
  } else {
    return usingOwnServer(chosen);
  }
};

setupPackageJSON = function(chosen) {
  var jPath;
  logger.debug("Making package.json edits");
  jPath = path.join(skeletonOutPath, "package.json");
  packageJson = require(jPath);
  if (projectName) {
    packageJson.name = projectName;
  }
  if (Object.keys(devDependencies).length > 0) {
    packageJson.devDependencies = devDependencies;
  }
  if (chosen.server.library) {
    [chosen.views, chosen.javascript, chosen.server].forEach(function(chosenItem) {
      if (chosenItem.version) {
        return packageJson.dependencies[chosenItem.library] = chosenItem.version;
      }
    });
  } else {
    delete packageJson.dependencies;
  }
  return fs.writeFileSync(jPath, JSON.stringify(packageJson, null, 2));
};

runNPMInstall = function() {
  var currentDir, msg;
  if ((packageJson.dependencies && Object.keys(packageJson.dependencies).length > 0) || packageJson.devDependencies) {
    msg = "Installing";
    if (packageJson.dependencies && Object.keys(packageJson.dependencies).length > 0) {
      msg += " application";
      if (packageJson.devDependencies) {
        msg += " and";
      }
    }
    if (packageJson.devDependencies) {
      msg += " Mimosa development";
    }
    msg += " node modules. This may take a few seconds.";
    logger.info(msg);
    currentDir = process.cwd();
    process.chdir(skeletonOutPath);
    return exec("npm install", function(err, sout, serr) {
      if (err) {
        logger.error(err);
      } else {
        console.log(sout);
      }
      logger.debug("Node module install sout: " + sout);
      logger.debug("Node module install serr: " + serr);
      process.chdir(currentDir);
      return writeConfigs();
    });
  } else {
    return writeConfigs();
  }
};

writeConfigs = function() {
  var configPath, outConfigText;
  configPath = path.join(skeletonOutPath, "mimosa-config.js");
  outConfigText = "exports.config = " + JSON.stringify(outConfig, null, 2);
  return fs.writeFile(configPath, outConfigText, function(err) {
    var currentDir;
    currentDir = process.cwd();
    process.chdir(skeletonOutPath);
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

prompting = function() {
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
  return program.choose(_.pluck(compilers.javascript, 'prettyName'), function(i) {
    var chosen;
    logger.blue("\n  You chose " + compilers.javascript[i].prettyName + ".");
    chosen = {
      javascript: compilers.javascript[i]
    };
    logger.green("\n  Choose your CSS meta-language:\n");
    return program.choose(_.pluck(compilers.css, 'prettyName'), function(i) {
      logger.blue("\n  You chose " + compilers.css[i].prettyName + ".");
      chosen.css = compilers.css[i];
      logger.green("\n  Choose your micro-templating language:\n");
      return program.choose(_.pluck(compilers.template, 'prettyName'), function(i) {
        logger.blue("\n  You chose " + compilers.template[i].prettyName + ".");
        chosen.template = compilers.template[i];
        logger.green("\n  Choose your server technology: \n");
        return program.choose(_.pluck(servers, 'prettyName'), function(i) {
          logger.blue("\n  You chose " + servers[i].prettyName + ".");
          chosen.server = servers[i];
          logger.green("\n  And finally choose your server view templating library:\n");
          return program.choose(_.pluck(views, 'prettyName'), function(i) {
            logger.blue("\n  You chose " + views[i].prettyName + ".");
            chosen.views = views[i];
            logger.green("\n  Creating and setting up your project... \n");
            return create(chosen);
          });
        });
      });
    });
  });
};

newProject = function(name, opts) {
  var outPath;
  if (opts.mdebug) {
    opts.debug = true;
    logger.setDebug();
    process.env.DEBUG = true;
  }
  outConfig.modules = moduleManager.builtIns.map(function(builtIn) {
    return builtIn.substring(7);
  });
  logger.debug("Project name: " + name);
  if (name) {
    projectName = name;
    outPath = path.join(process.cwd(), projectName);
    if (fs.existsSync(outPath)) {
      logger.error("Directory/file exists at [[ " + outPath + " ]], cannot continue.");
      process.exit(0);
    }
    skeletonOutPath = outPath;
  }
  if (opts.defaults) {
    return createWithDefaults();
  } else {
    return prompting();
  }
};

register = function(prog) {
  program = prog;
  return program.command('new [name]').description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup").option("-d, --defaults", "bypass prompts and go with Mimosa defaults (CoffeeScript, Stylus, Handlebars)").option("-D, --mdebug", "run in debug mode").action(newProject).on('--help', printHelp);
};

module.exports = register;
