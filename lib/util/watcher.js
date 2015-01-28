var Watcher, Workflow, logger, watch,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

watch = require('chokidar');

logger = require('logmimosa');

Workflow = require('./workflow');

Watcher = (function() {
  Watcher.prototype.adds = [];

  function Watcher(config, modules, persist, initCallback) {
    this.config = config;
    this.persist = persist;
    this.initCallback = initCallback;
    this._ignoreFunct = __bind(this._ignoreFunct, this);
    this._pullFiles = __bind(this._pullFiles, this);
    this._buildDoneCallback = __bind(this._buildDoneCallback, this);
    this._fileUpdated = __bind(this._fileUpdated, this);
    this._startWatcher = __bind(this._startWatcher, this);
    this.throttle = this.config.watch.throttle;
    this.workflow = new Workflow(this.config, modules, this._buildDoneCallback);
    this.workflow.initBuild(this._startWatcher);
  }

  Watcher.prototype._startWatcher = function() {
    var watchConfig, watcher,
      _this = this;
    watchConfig = {
      ignored: this._ignoreFunct,
      persistent: this.persist,
      interval: this.config.watch.interval,
      binaryInterval: this.config.watch.binaryInterval,
      usePolling: this.config.watch.usePolling
    };
    watcher = watch.watch(this.config.watch.sourceDir, watchConfig);
    process.on('STOPMIMOSA', function() {
      return watcher.close();
    });
    watcher.on("error", function(error) {
      return logger.warn("File watching error: " + error);
    });
    watcher.on("change", function(f) {
      return _this._fileUpdated('update', f);
    });
    watcher.on("unlink", this.workflow.remove);
    watcher.on("ready", this.workflow.ready);
    watcher.on("add", function(f) {
      if (_this.throttle > 0) {
        return _this.adds.push(f);
      } else {
        return _this._fileUpdated('add', f);
      }
    });
    if (this.persist) {
      logger.info("Watching [[ " + this.config.watch.sourceDir + " ]]");
    }
    if (this.throttle > 0) {
      logger.debug("Throttle is set, setting interval at 100 milliseconds");
      this.intervalId = setInterval(this._pullFiles, 100);
      return this._pullFiles();
    }
  };

  Watcher.prototype._fileUpdated = function(eventType, f) {
    var _this = this;
    if (this.config.watch.delay > 0) {
      return setTimeout(function() {
        return _this.workflow[eventType](f);
      }, this.config.watch.delay);
    } else {
      return this.workflow[eventType](f);
    }
  };

  Watcher.prototype._buildDoneCallback = function() {
    logger.buildDone();
    if ((this.intervalId != null) && !this.persist) {
      clearInterval(this.intervalId);
    }
    if (this.initCallback != null) {
      return this.initCallback(this.config);
    }
  };

  Watcher.prototype._pullFiles = function() {
    var f, filesToAdd, _i, _len, _results;
    if (this.adds.length === 0) {
      return;
    }
    filesToAdd = this.adds.length <= this.throttle ? this.adds.splice(0, this.adds.length) : this.adds.splice(0, this.throttle);
    _results = [];
    for (_i = 0, _len = filesToAdd.length; _i < _len; _i++) {
      f = filesToAdd[_i];
      _results.push(this.workflow.add(f));
    }
    return _results;
  };

  Watcher.prototype._ignoreFunct = function(name) {
    var exclude, _i, _len, _ref;
    if (this.config.watch.excludeRegex != null) {
      if (name.match(this.config.watch.excludeRegex)) {
        logger.debug("Ignoring file [[ " + name + " ]], matches exclude regex");
        return true;
      }
    }
    if (this.config.watch.exclude != null) {
      _ref = this.config.watch.exclude;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        exclude = _ref[_i];
        if (name.indexOf(exclude) === 0) {
          logger.debug("Ignoring file [[ " + name + " ]], matches exclude string path");
          return true;
        }
      }
    }
    return false;
  };

  return Watcher;

})();

module.exports = Watcher;
