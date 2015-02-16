var watch =  require( "chokidar" )
  , _ = require( "lodash" )
  , Workflow = require( "./workflow" )
  , watchUtil = require( "./watch-util" )
  ;

function Cleaner( config, modules, initCallback ) {
  this.config = config;
  this.initCallback = initCallback;
  var configClone = _.clone( this.config, true );
  this.workflow = new Workflow( configClone, modules, this.cleanDone.bind( this ) );
  this.workflow.initClean( this.startWatcher.bind( this ) );
}

Cleaner.prototype.startWatcher = function() {
  var watchConfig = watchUtil.watchConfig( this.config, false );
  this.watcher = watch.watch( this.config.watch.sourceDir, watchConfig );
  this.watcher.on( "add", this.workflow.clean );
  this.watcher.on( "ready", this.workflow.ready );
};

Cleaner.prototype.cleanDone = function() {
  this.workflow.postClean( function postCleanCallback(){
    this.watcher.close();
    this.initCallback();
  }.bind( this ));
};

module.exports = Cleaner;
