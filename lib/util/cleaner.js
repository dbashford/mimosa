var Cleaner, Workflow, logger, watch, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

watch = require('chokidar');

logger = require('logmimosa');

_ = require('lodash');

Workflow = require('./workflow');

Cleaner = (function() {
  function Cleaner(config, modules, initCallback) {
    this.config = config;
    this.initCallback = initCallback;
    this._ignoreFunct = __bind(this._ignoreFunct, this);
    this._cleanDone = __bind(this._cleanDone, this);
    this._startWatcher = __bind(this._startWatcher, this);
    this.workflow = new Workflow(_.clone(this.config, true), modules, this._cleanDone);
    this.workflow.initClean(this._startWatcher);
  }

  Cleaner.prototype._startWatcher = function() {
    var watchConfig;
    watchConfig = {
      ignored: this._ignoreFunct,
      persistent: false,
      interval: this.config.watch.interval,
      binaryInterval: this.config.watch.binaryInterval,
      usePolling: this.config.watch.usePolling
    };
    this.watcher = watch.watch(this.config.watch.sourceDir, watchConfig);
    this.watcher.on("add", this.workflow.clean);
    return this.watcher.on("ready", this.workflow.ready);
  };

  Cleaner.prototype._cleanDone = function() {
    var _this = this;
    return this.workflow.postClean(function() {
      _this.watcher.close();
      return _this.initCallback();
    });
  };

  Cleaner.prototype._ignoreFunct = function(name) {
    if (this.config.watch.excludeRegex != null) {
      if (name.match(this.config.watch.excludeRegex)) {
        logger.debug("Ignoring file [[ " + name + " ]], matches exclude regex");
        return true;
      }
    }
    if (this.config.watch.exclude != null) {
      if (this.config.watch.exclude.indexOf(name) > -1) {
        logger.debug("Ignoring file [[ " + name + " ]], matches exclude string path");
        return true;
      }
    }
    return false;
  };

  return Cleaner;

})();

module.exports = Cleaner;
