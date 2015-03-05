var crypto = require( "crypto" )
  , path = require( "path" )
  , fs = require( "fs" )
  , wrench = require( "wrench" )
  , sinon = require( "sinon" )
  , _ = require( "lodash" )
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
  , standardConfig = {
    modules: ['copy'],
    logger: {
      growl: {
        enabled: false
      }
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

var stubChokidar = function() {
  var chokidar = require( "chokidar" );
  var stub = sinon.stub(chokidar, "watch", function() {
    var noop = function(){};
    return {
      on: noop,
      close: noop
    };
  })
  return stub;
};

var restoreChokidar = function() {
  var chokidar = require( "chokidar" );
  if (chokidar.watch.restore) {
    chokidar.watch.restore();
  }
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
  var projectDirectory = path.join( __dirname, "..", "harness", "run", projectPath );
  var assetsDirectory = path.join( projectDirectory, "assets")
  var mimosaConfig = path.join( projectDirectory, "mimosa-config.js" );
  var publicDirectory = path.join( projectDirectory, "public" );
  var javascriptOutDirectory = path.join( publicDirectory, "javascripts" );
  var javascriptInDirectory = path.join( assetsDirectory, "javascripts" );

  return {
    projectPath: projectPath,
    projectName: projectName,
    projectDir: projectDirectory,
    assetsDir: assetsDirectory,
    publicDir: publicDirectory,
    javascriptOutDir: javascriptOutDirectory,
    javascriptInDir: javascriptInDirectory,
    mimosaConfig: mimosaConfig
  };
};

var setupProject = function( env, inProjectName ) {
  wrench.mkdirSyncRecursive(env.projectDir, 0777);

  // copy project skeleton in
  var inProjectPath = path.join( __dirname, "..", "harness", "projects", inProjectName );
  wrench.copyDirSyncRecursive( inProjectPath, env.projectDir, { forceDelete: true } );

  // copy correct mimosa-config in
  var configInPath = path.join( __dirname, "..", "harness", "configs", env.projectPath + ".js" );
  var configText;
  if (fs.existsSync( configInPath )) {
    configText = fs.readFileSync( configInPath, "utf8" );
  } else {
    configText = "exports.config = " + JSON.stringify(standardConfig, null, 2);
  }
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

var fakeProgram = function() {
  var program = {
    on: function() { return program },
    command: function(){ return program },
    description: function(){ return program },
    command: function(){return program },
    option: function(){return program },
    action: function(){ return program }
  };
  return program;
};

module.exports = {
  fileFixture: fileFixture,
  fakeMimosaConfig: fakeMimosaConfig,
  testRegistration: testRegistration,
  setupProjectData: setupProjectData,
  setupProject: setupProject,
  cleanProject: cleanProject,
  filesAndDirsInFolder: filesAndDirsInFolder,
  fakeProgram: fakeProgram,
  stubChokidar: stubChokidar,
  restoreChokidar: restoreChokidar
};