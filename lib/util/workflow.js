var WorkflowManager, compilers, fileUtils, fs, logger, path, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

_ = require('lodash');

logger = require('logmimosa');

compilers = require('../modules/compilers');

fileUtils = require('./file');

module.exports = WorkflowManager = (function() {
  WorkflowManager.prototype.startup = true;

  WorkflowManager.prototype.initialFilesHandled = 0;

  WorkflowManager.prototype.registration = {};

  WorkflowManager.prototype.doneFiles = [];

  WorkflowManager.prototype.masterTypes = {
    preClean: ["init", "complete"],
    cleanFile: ["init", "beforeRead", "read", "afterRead", "beforeDelete", "delete", "afterDelete", "complete"],
    postClean: ["init", "complete"],
    preBuild: ["init", "complete"],
    buildFile: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "complete"],
    buildExtension: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "complete"],
    postBuild: ["init", "beforeOptimize", "optimize", "afterOptimize", "beforeServer", "server", "afterServer", "beforePackage", "package", "afterPackage", "beforeInstall", "install", "afterInstall", "complete"],
    add: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"],
    update: ["init", "beforeRead", "read", "afterRead", "betweenReadCompile", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"],
    remove: ["init", "beforeRead", "read", "afterRead", "beforeDelete", "delete", "afterDelete", "beforeCompile", "compile", "afterCompile", "betweenCompileWrite", "beforeWrite", "write", "afterWrite", "betweenWriteOptimize", "beforeOptimize", "optimize", "afterOptimize", "complete"]
  };

  function WorkflowManager(config, modules, buildDoneCallback) {
    var module, step, steps, type, _i, _j, _len, _len1, _ref;

    this.config = config;
    this.buildDoneCallback = buildDoneCallback;
    this._buildDone = __bind(this._buildDone, this);
    this._buildExtensions = __bind(this._buildExtensions, this);
    this._finishedWithFile = __bind(this._finishedWithFile, this);
    this.add = __bind(this.add, this);
    this.remove = __bind(this.remove, this);
    this.update = __bind(this.update, this);
    this.clean = __bind(this.clean, this);
    this.register = __bind(this.register, this);
    this.cleanUpRegistration = __bind(this.cleanUpRegistration, this);
    this.postClean = __bind(this.postClean, this);
    this.determineFileCount = __bind(this.determineFileCount, this);
    this.initBuild = __bind(this.initBuild, this);
    this.initClean = __bind(this.initClean, this);
    compilers.setupCompilers(this.config);
    this.types = _.clone(this.masterTypes, true);
    _ref = this.types;
    for (type in _ref) {
      steps = _ref[type];
      this.registration[type] = {};
      for (_i = 0, _len = steps.length; _i < _len; _i++) {
        step = steps[_i];
        this.registration[type][step] = {};
      }
    }
    this.allExtensions = [];
    for (_j = 0, _len1 = modules.length; _j < _len1; _j++) {
      module = modules[_j];
      if (module.registration != null) {
        module.registration(this.config, this.register);
      }
    }
    this.allExtensions = _.uniq(this.allExtensions);
    this.cleanUpRegistration();
    this.determineFileCount();
  }

  WorkflowManager.prototype.initClean = function(cb) {
    return this._executeWorkflowStep({}, 'preClean', cb);
  };

  WorkflowManager.prototype.initBuild = function(cb) {
    var _this = this;

    return this._executeWorkflowStep({}, 'preBuild', function() {
      _this.determineFileCount();
      return cb();
    });
  };

  WorkflowManager.prototype.determineFileCount = function() {
    var files, w,
      _this = this;

    w = this.config.watch;
    files = fileUtils.readdirSyncRecursive(w.sourceDir, w.exclude, w.excludeRegex, true).filter(function(f) {
      var ext;

      ext = path.extname(f).substring(1);
      return ext.length >= 1 && _this.allExtensions.indexOf(ext) >= 0;
    });
    return this.initialFileCount = files.length;
  };

  WorkflowManager.prototype.postClean = function(cb) {
    return this._executeWorkflowStep({}, 'postClean', cb);
  };

  WorkflowManager.prototype.cleanUpRegistration = function() {
    var i, st, step, stepReg, type, typeReg, _ref, _results;

    logger.debug("Cleaning up unused workflow steps");
    _ref = this.registration;
    _results = [];
    for (type in _ref) {
      typeReg = _ref[type];
      _results.push((function() {
        var _i, _len, _ref1, _results1;

        _results1 = [];
        for (step in typeReg) {
          stepReg = typeReg[step];
          if (Object.keys(stepReg).length === 0) {
            i = 0;
            _ref1 = this.types[type];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              st = _ref1[_i];
              if (st === step) {
                this.types[type].splice(i, 1);
                break;
              }
              i++;
            }
            _results1.push(delete typeReg[step]);
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  WorkflowManager.prototype.register = function(types, step, callback, extensions) {
    var extension, type, _base, _i, _j, _len, _len1, _ref, _ref1;

    if (extensions == null) {
      extensions = ['*'];
    }
    if (!Array.isArray(types)) {
      return logger.warn("Workflow types not passed in as array: [[ " + types + " ]], ending registration for module.");
    }
    if (!Array.isArray(extensions)) {
      return logger.warn("Workflow extensions not passed in as array: [[ " + extensions + " ]], ending registration for module.");
    }
    if (typeof step !== "string") {
      return logger.warn("Workflow step not passed in as string: [[ " + step + " ]], ending registration for module.");
    }
    if (!_.isFunction(callback)) {
      return logger.warn("Workflow callback not passed in as function: [[ " + callback + " ]], ending registration for module.");
    }
    for (_i = 0, _len = types.length; _i < _len; _i++) {
      type = types[_i];
      if (this.types[type] == null) {
        return logger.warn("Unrecognized workflow type [[ " + type + " ]], valid types are [[ " + (Object.keys(this.types).join(',')) + " ]], ending registration for module.");
      }
      if (this.types[type].indexOf(step) < 0) {
        return logger.warn("Unrecognized workflow step [[ " + step + " ]] for type [[ " + type + " ]], valid steps are [[ " + this.types[type] + " ]]");
      }
      _ref = _.uniq(extensions);
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        extension = _ref[_j];
        extension = extension.toLowerCase();
        if (this.registration[type][step][extension] != null) {
          if (this.registration[type][step][extension].indexOf(callback) >= 0) {
            logger.debug("Callback already registered for this extension, ignoring:", type, step, extension);
            continue;
          }
        } else {
          if ((_ref1 = (_base = this.registration[type][step])[extension]) == null) {
            _base[extension] = [];
          }
        }
        this.allExtensions.push(extension);
        this.registration[type][step][extension].push(callback);
      }
    }
  };

  WorkflowManager.prototype.clean = function(fileName) {
    return this._executeWorkflowStep(this._buildAssetOptions(fileName), 'cleanFile');
  };

  WorkflowManager.prototype.update = function(fileName) {
    return this._executeWorkflowStep(this._buildAssetOptions(fileName), 'update');
  };

  WorkflowManager.prototype.remove = function(fileName) {
    return this._executeWorkflowStep(this._buildAssetOptions(fileName), 'remove');
  };

  WorkflowManager.prototype.add = function(fileName) {
    if (this.startup) {
      return this._executeWorkflowStep(this._buildAssetOptions(fileName), 'buildFile');
    } else {
      return this._executeWorkflowStep(this._buildAssetOptions(fileName), 'add');
    }
  };

  WorkflowManager.prototype._buildAssetOptions = function(fileName) {
    var ext;

    ext = path.extname(fileName).toLowerCase();
    ext = ext.length > 1 ? ext.substring(1) : '';
    return {
      inputFile: fileName,
      extension: ext
    };
  };

  WorkflowManager.prototype._executeWorkflowStep = function(options, type, done) {
    var cb, i, next, _ref,
      _this = this;

    if (done == null) {
      done = this._finishedWithFile;
    }
    options.lifeCycleType = type;
    if (options.inputFile != null) {
      if (options.extension.length === 0 && fs.existsSync(options.inputFile) && fs.statSync(options.inputFile).isDirectory()) {
        return logger.debug("Not handling directory [[ " + options.inputFile + " ]]");
      }
      if (this.allExtensions.indexOf(options.extension) === -1) {
        if (((_ref = options.extension) != null ? _ref.length : void 0) === 0) {
          return logger.debug("No extension detected [[ " + options.inputFile + " ]].");
        } else {
          return logger.warn("No module has registered for extension: [[ " + options.extension + " ]], file: [[ " + options.inputFile + " ]]");
        }
      }
    }
    i = 0;
    next = function() {
      if (i < _this.types[type].length) {
        return _this._workflowMethod(type, _this.types[type][i++], options, cb);
      } else {
        return done(options);
      }
    };
    cb = function(nextVal) {
      if (_.isBoolean(nextVal) && !nextVal) {
        return done(options);
      } else {
        return next();
      }
    };
    return next();
  };

  WorkflowManager.prototype._workflowMethod = function(type, step, options, done) {
    var cb, ext, i, next, tasks,
      _this = this;

    tasks = [];
    ext = options.extension;
    step = this.registration[type][step];
    if (step[ext] != null) {
      tasks.push.apply(tasks, step[ext]);
    }
    if (step['*'] != null) {
      tasks.push.apply(tasks, step['*']);
    }
    i = 0;
    next = function() {
      if (i < tasks.length) {
        return tasks[i++](_this.config, options, cb);
      } else {
        return done();
      }
    };
    cb = function(nextVal) {
      if (_.isBoolean(nextVal) && !nextVal) {
        return done(false);
      } else {
        return next();
      }
    };
    return next();
  };

  WorkflowManager.prototype.hash = {};

  WorkflowManager.prototype._finishedWithFile = function(options) {
    logger.debug("Finished with file: [[ " + options.inputFile + " ]]");
    if (this.startup && ++this.initialFilesHandled === this.initialFileCount) {
      if (this.config.isClean) {
        if (this.buildDoneCallback != null) {
          return this.buildDoneCallback();
        }
      } else {
        return this._buildExtensions();
      }
    }
  };

  WorkflowManager.prototype._buildExtensions = function() {
    var done,
      _this = this;

    this.startup = false;
    done = 0;
    return this.allExtensions.forEach(function(extension) {
      return _this._executeWorkflowStep({
        extension: extension
      }, 'buildExtension', function() {
        if (++done === _this.allExtensions.length) {
          return _this._buildDone();
        }
      });
    });
  };

  WorkflowManager.prototype._buildDone = function() {
    var _this = this;

    return this._executeWorkflowStep({}, 'postBuild', function() {
      if (_this.buildDoneCallback != null) {
        return _this.buildDoneCallback();
      }
    });
  };

  return WorkflowManager;

})();
