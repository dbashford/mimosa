// utilities that spawn mimosa build processes

var exec = require('child_process').exec
  , spawn = require( 'child_process' ).spawn
  , utils = require( "../utils" )
  ;

var _mimosaCommandTestWrapper = function( testOpts, runCommand ) {
  describe("", function() {
    var projectData;

    before(function(){
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
    });

    after(function(){
      utils.cleanProject( projectData );
    })

    it(testOpts.testSpec, function(done){
      var cwd = process.cwd();
      process.chdir( projectData.projectDir );
      runCommand( projectData, function() {
        done();
        process.chdir(cwd);
      });
    });
  });
};

var spawnWatchTest = function( testOpts ) {
  var runCommand = function( projectData, cb ) {
    var data = ""
      , errData = ""
      , finished = false
      , killed = false
      , flags = testOpts.watchFlags

    var flags = ['watch'];
    if (testOpts.watchFlags) {
      flags = [].concat.apply(flags, testOpts.watchFlags.split(" "))
    }

    var mimosaProc = spawn( 'mimosa', flags );

    var killAndTest = function() {
      killed = true;
      setTimeout( function() {
        mimosaProc.kill("SIGINT");
        // not going to bother collecting all the outputs
        var _data = {
          error:null,
          sout:data,
          serr:errData
        };
        testOpts.asserts( _data, projectData, cb );
      }, 100);
    };

    mimosaProc.on('exit', function() {
      if (!killed) {
        killAndTest();
      }
    });

    mimosaProc.stderr.on( 'data', function ( _data ) {
      errData += _data;
    });

    mimosaProc.stdout.on( 'data', function ( _data ) {
      data += _data;
      var len = 0;
      var successes = data.match( /Wrote file/g );
      if (successes) {
        len = successes.length;
      }

      // all the files processed, now what?
      if ( len === testOpts.fileSuccessCount && !finished) {
        if (testOpts.postWatch) {
          // post watch things need to be delayed
          // to allow build to transition to watch fully
          setTimeout( function() {
            testOpts.postWatch(projectData, killAndTest);
          }, 600);
        } else {
          killAndTest();
        }
        finished = true;
      }
    });
  };
  _mimosaCommandTestWrapper( testOpts, runCommand );
};

var spawnBuildTest = function(testOpts) {
  var runCommand = function( projectData, cb ) {
    exec( "mimosa build " + testOpts.buildFlags || "", function ( err, sout, serr ) {
      testOpts.asserts({
          error:err,
          sout:sout,
          serr:serr
        }
        , projectData
        , cb);
    });
  };
  _mimosaCommandTestWrapper( testOpts, runCommand );
};

var spawnBuildCleanTest = function( testOpts ) {
  var runCommand = function( projectData, cb ) {
    exec( "mimosa build " + testOpts.buildFlags || "", function ( err, sout, serr ) {
      exec( "mimosa clean " + testOpts.cleanFlags || "", function ( err, sout, serr ) {
        testOpts.asserts({
            error:err,
            sout:sout,
            serr:serr
          }
          , projectData
          , cb);
      });
    });
  };
  _mimosaCommandTestWrapper( testOpts, runCommand );
};

var spawnCleanTest = function( testOpts ) {
  var runCommand = function( projectData, cb ) {
    exec( "mimosa clean " + testOpts.cleanFlags || "", function ( err, sout, serr ) {
      testOpts.asserts({
          error:err,
          sout:sout,
          serr:serr
        }
        , projectData
        , cb);
    });
  };
  _mimosaCommandTestWrapper( testOpts, runCommand );
};


// for now, don't run spawn based tests on travis
if (__dirname.indexOf("/travis/") > 0) {
  module.exports = {
    buildTest: function(){},
    buildCleanTest: function(){},
    watchTest: function(){},
    cleanTest: function(){}
  };
} else {
  module.exports = {
    buildTest: spawnBuildTest,
    buildCleanTest: spawnBuildCleanTest,
    watchTest: spawnWatchTest,
    cleanTest: spawnCleanTest
  };
}