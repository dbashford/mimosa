var watch = require( "chokidar" )
  , logger = require( "logmimosa" )
  , watchUtil = require( "./watch-util" )
  , Workflow = require( "./workflow" )
  ;

function Watcher( config, modules, persist, initCallback ) {
  this.adds = [];
  this.config = config;
  this.persist = persist;
  this.initCallback = initCallback;
  this.throttle = this.config.watch.throttle;

  this.workflow = new Workflow( this.config, modules, this.buildDoneCallback.bind( this ) );
  this.workflow.initBuild( this.startWatcher.bind( this ) );
}

Watcher.prototype.stopWatching = function() {
  if ( this.intervalId ) {
    clearInterval( this.intervalId );
  }
  this.watcher.close();
};

Watcher.prototype.startWatcher = function() {
  var watchConfig = watchUtil.watchConfig( this.config, true );
  this.watcher = watch.watch( this.config.watch.sourceDir, watchConfig );
  var _this = this;

  // set up way for mimosa process to stop watching at any time
  process.on( "STOPMIMOSA", this.stopWatching.bind( this ) );

  this.watcher.on( "error", function( error ) {
    logger.warn( "File watching error: " + error );
  });
  this.watcher.on( "change", function( file ) {
    _this.fileUpdated( "update", file );
  });
  this.watcher.on( "unlink", this.workflow.remove );
  this.watcher.on( "ready", this.workflow.ready );
  this.watcher.on( "add", function( file ) {
    // if throttle engaged, just maintain list of adds
    if ( _this.throttle ) {
      _this.adds.push( file );
    } else {
      _this.fileUpdated( "add", file );
    }
  });

  if ( this.persist ) {
    logger.info( "Watching [[ " + this.config.watch.sourceDir + " ]]" );
  }

  if ( this.throttle ) {
    this.intervalId = setInterval( this.pullFiles.bind( this ), 100 );
    this.pullFiles();
  }
};

Watcher.prototype.fileUpdated = function ( eventType, file ) {
  // sometimes events can be sent before
  // file isn't finished being written
  // https://github.com/dbashford/mimosa/issues/392
  if ( this.config.watch.delay ) {
    setTimeout( function() {
      this.workflow[eventType]( file );
    }.bind( this ), this.config.watch.delay );
  } else {
    this.workflow[eventType]( file );
  }
};

Watcher.prototype.buildDoneCallback = function() {
  logger.buildDone();

  if ( this.intervalId && !this.persist ) {
    clearInterval( this.intervalId );
  }

  if ( this.initCallback ) {
    this.initCallback( this.config );
  }
};

Watcher.prototype.pullFiles = function() {
  var addLength = this.adds.length;
  if ( !addLength ) {
    return;
  }

  var spliceNum = (addLength <= this.throttle) ? addLength : this.throttle;
  var filesToAdd = this.adds.splice( 0, spliceNum );

  for ( var i = 0; i < filesToAdd.length; i++ ) {
    this.workflow.add( filesToAdd[i] );
  }
};

module.exports = Watcher;
