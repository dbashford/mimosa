var crypto = require( "crypto" )
  , exec = require('child_process').exec
  , spawn = require( 'child_process' ).spawn
  , path = require( "path" )
  , fs = require( "fs" )
  , wrench = require( "wrench" )
  , _ = require( "lodash" )
  , wrench = require( "wrench" )
  , rimraf = require( "rimraf" )
  , fakeMimosaConfigObj = {
    watch: {
      compiledDir:"foo",
      sourceDir:"bar"
    },
    extensions: {
      javascript:["js", "coffee"],
      css:["less"],
      template:["hog", "hogan"],
      copy:["html", "htm"],
      misc:["foo"]
    },
    log: {
      success: function(msg, opts){},
      warn: function(msg, opts){},
      error: function(msg, opts){},
      isDebug: function(){return false;}
    },
    vendor: {
      javascripts: "javascripts/vendor",
      stylesheets: "stylesheets/vendor"
    }
  }
  ;

var randomString = function( num ) {
  return crypto.randomBytes(num || 64).toString( "hex" );
};

var fileFixture = function() {
  var fixture = {
    inputFileName: path.join( __dirname, "tmp", randomString(3) + ".js" ),
    inputFileText: randomString(),
    outputFileName: path.join( __dirname, "tmp", randomString(3) + "fixture_outtest1.js" ),
    outputFileText: randomString()
  };

  return fixture;
};

var fakeMimosaConfig = function() {
  return _.cloneDeep(fakeMimosaConfigObj);
};

var testRegistration = function( mod, cb, noExtensions ) {
  var workflows, step, writeFunction, extensions;

  mod.registration( fakeMimosaConfig(), function( _workflows, _step , _writeFunction, _extensions ) {
    workflows = _workflows;
    step = _step;
    writeFunction = _writeFunction;
    extensions = _extensions;

    expect( workflows ).to.be.instanceof( Array );
    expect( step ).to.be.a( "string" );
    expect( writeFunction ).to.be.instanceof( Function )
    if ( !noExtensions ) {
      expect( extensions ).to.be.instanceof( Array );
    }

    cb( writeFunction );
  });
};

var setupProjectData = function( projectName ) {
  var projectPath = projectName.split("/").join(path.sep);
  var projectDirectory = path.join( __dirname, "harness", "run", projectPath );
  var mimosaConfig = path.join( projectDirectory, "mimosa-config.js" );
  var publicDirectory = path.join( projectDirectory, "public" );
  var javascriptDirectory = path.join( publicDirectory, "javascripts" );

  return {
    projectPath: projectPath,
    projectName: projectName,
    projectDir: projectDirectory,
    publicDir: publicDirectory,
    javascriptDir: javascriptDirectory,
    mimosaConfig: mimosaConfig
  };
};

var setupProject = function( env, inProjectName ) {
  wrench.mkdirSyncRecursive(env.projectDir, 0777);

  // copy project skeleton in
  var inProjectPath = path.join( __dirname, "harness", "projects", inProjectName );
  wrench.copyDirSyncRecursive( inProjectPath, env.projectDir, { forceDelete: true } );

  // copy correct mimosa-config in
  var configInPath = path.join( __dirname, "harness", "configs", env.projectPath + ".js" );
  var configText = fs.readFileSync( configInPath, "utf8" );
  fs.writeFileSync(env.mimosaConfig, configText);
};

var cleanProject = function( env ) {
  // clean out cache
  if ( fs.existsSync( env.projectDir ) ) {
    rimraf.sync( env.projectDir );
  }
};

var filesAndDirsInFolder = function( dir ) {
  return wrench.readdirSyncRecursive( dir ).length;
};

var mimosaCommandTestWrapper = function( testOpts, runCommand ) {
  describe("", function() {
    var projectData;

    before(function(){
      projectData = setupProjectData( testOpts.configFile );
      cleanProject( projectData );
      setupProject( projectData, testOpts.project );
    });

    after(function(){
      cleanProject( projectData );
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

var runWatchThenTest = function( testOpts ) {
  var runCommand = function( projectData, cb ) {
    var data = "";
    var mimosaProc = spawn( 'mimosa', ['watch'] );
    var killAndTest = function() {
      setTimeout( function() {
        mimosaProc.kill("SIGINT");
        testOpts.asserts( data, projectData, cb );
      }, 200);
    };

    mimosaProc.stdout.on( 'data', function ( _data ) {
      data += _data;
      var len = 0;
      var successes = data.match( /Success/g );
      if (successes) {
        len = successes.length;
      }

      // all the files processed, now what?
      if ( len === testOpts.fileSuccessCount ) {
        if (testOpts.postWatch) {
          testOpts.postWatch(projectData, killAndTest);
        } else {
          killAndTest();
        }
      }
    });
  };
  mimosaCommandTestWrapper( testOpts, runCommand );
};

var runBuildThenTest = function(testOpts) {
  var runCommand = function( projectData, cb ) {
    exec( "mimosa build", function ( err, sout, serr ) {
      testOpts.asserts(sout, projectData, cb)
    });
  };
  mimosaCommandTestWrapper( testOpts, runCommand );
};

var runBuildAndCleanThenTest = function( testOpts ) {
  var runCommand = function( projectData, cb ) {
    exec( "mimosa build", function ( err, sout, serr ) {
      exec( "mimosa clean", function ( err, sout, serr ) {
        testOpts.asserts(sout, projectData, cb);
      });
    });
  };
  mimosaCommandTestWrapper( testOpts, runCommand );
};


module.exports = {
  fileFixture: fileFixture,
  fakeMimosaConfig: fakeMimosaConfig,
  testRegistration: testRegistration,
  setupProjectData: setupProjectData,
  setupProject: setupProject,
  cleanProject: cleanProject,
  runBuildThenTest: runBuildThenTest,
  filesAndDirsInFolder: filesAndDirsInFolder,
  runBuildAndCleanThenTest: runBuildAndCleanThenTest,
  runWatchThenTest: runWatchThenTest
};