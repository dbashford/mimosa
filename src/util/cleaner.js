var watch =  require( "chokidar" )
  , _ = require( "lodash" )
  , Workflow = require( "./workflow" )
  , watchUtil = require( "./watch-util" )
  , config
  , initCallback
  , workflow
  , watcher
  ;

var _cleanDone = function() {
  workflow.postClean(function postCleanCallback(){
    watcher.close();
    initCallback();
  });
};

var _startWatcher = function() {
  var watchConfig = watchUtil.watchConfig( config, false );
  watcher = watch.watch( config.watch.sourceDir, watchConfig );
  watcher.on( "add", workflow.clean );
  watcher.on( "ready", workflow.ready );
};

var clean = function( _config, modules, _initCallback ) {
  config = _config;
  initCallback = _initCallback;
  var configClone = _.clone( config, true );
  workflow = new Workflow( configClone, modules, _cleanDone );
  workflow.initClean( _startWatcher );
};

module.exports = clean;
