var path = require( "path" )
  , sinon  = require( "sinon" )
  , utils = require( "../utils" )
  , logger = require( "logmimosa" )
  , configurerPath = path.join(process.cwd(), "lib", "util", "configurer")
  , watcherPath = path.join(process.cwd(), "lib", "util", "watcher")
  , cleanerPath = path.join(process.cwd(), "lib", "util", "cleaner")
  ;

var _spyOutput = function( spy ) {
  var out = "";
  var callCount = spy.callCount
  for ( var i = 0; i < callCount; i++ ) {
    out += spy.getCall(i).args[0] + "\n";
  }
  return out;
};

var _buildWatchTest = function( testOpts ) {
  describe("", function() {
    var projectData
      , logSpy
      , errSpy
      , cwd
      ;

    var createSpyOutput = function() {
      return {
        log: _spyOutput( logSpy ),
        err: _spyOutput( errSpy )
      };
    };

    before(function(){
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      logSpy = sinon.spy(console, "log");
      errSpy = sinon.spy(console, "error");
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
    });

    after(function(){
      utils.cleanProject( projectData );
      console.log.restore();
      console.error.restore();
      process.chdir(cwd);
    });

    it(testOpts.testSpec, function(done){
      var configurer = require( configurerPath );
      var Watcher = require( watcherPath );

      configurer({build:!testOpts.isWatch}, function( config, modules ) {
        config.isClean = false;
        var watcher = new Watcher( config, modules, testOpts.isWatch, function() {
          var finished = function() {
            // stop watching even if build
            // as watching only stops when process
            // ends and that won't happen here
            watcher.stopWatching();
            testOpts.asserts(createSpyOutput(), projectData, done)
          };

          if (testOpts.postBuild) {
            testOpts.postBuild(projectData, function() {
              // post build is where addition writes/updates
              // occur, need to let those fully happen before
              // finishing
              setTimeout( function() {
                finished();
              }, 250)
            });
          } else {
            finished();
          }
        });
      });
    });
  });
};

var cleanTest = function( testOpts ) {
  describe("", function() {
    var projectData
      , logSpy
      , errSpy
      , cwd
      ;

    var createSpyOutput = function() {
      return {
        log: _spyOutput( logSpy ),
        err: _spyOutput( errSpy )
      };
    };

    before(function(){
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      logSpy = sinon.spy(console, "log");
      errSpy = sinon.spy(console, "error");
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
    });

    after(function(){
      utils.cleanProject( projectData );
      logSpy.restore();
      errSpy.restore();
      process.chdir(cwd);
    });

    it(testOpts.testSpec, function(done){
      var configurer = require( configurerPath );
      var Cleaner = require( cleanerPath );
      var Watcher = require( watcherPath );

      configurer({clean:true}, function( config, modules ) {
        config.isClean = true;
        var watcher = new Watcher( config, modules, testOpts.isWatch, function() {
          watcher.stopWatching();
          new Cleaner( config, modules, function() {
            // watcher.stopWatching();
            testOpts.asserts(createSpyOutput(), projectData, done)
          });
        });
      });
    });
  });
};

var buildTest = function( testOpts ) {
  testOpts.isWatch = false;
  _buildWatchTest(testOpts);
}

var watchTest = function( testOpts ) {
  testOpts.isWatch = true;
  _buildWatchTest(testOpts);
}

var commandHelpTest = function( command ) {
  describe("", function() {
    var loggerGreenSpy
      , loggerBlueSpy
      ;

    before(function() {
      loggerGreenSpy = sinon.spy(logger, "green");
      loggerBlueSpy = sinon.spy(logger, "blue");
    })

    after(function(){
      logger.green.restore();
      logger.blue.restore();
    });

    it("will print help", function( done ) {

      var program = utils.fakeProgram();
      program.on = function(flag, cb) {
        expect(flag).to.eql("--help");
        cb();
        expect(loggerGreenSpy.callCount).to.be.above(5);
        expect(loggerBlueSpy.callCount).to.be.above(5);
        done()
        return program;
      };

      command( program );
    });
  })
}

module.exports = {
  watchTest: watchTest,
  buildTest: buildTest,
  cleanTest: cleanTest,
  commandHelpTest: commandHelpTest
}
