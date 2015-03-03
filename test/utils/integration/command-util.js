var path = require( "path" )
  , fs = require( "fs" )
  , wrench = require( "wrench" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , spawn = require("./spawn")
  , utils = require("../utils")
  ;


// Tests a command to see if it properly
// handles bad command line flags
// i.e. flags it is not permitted to use
var testBadCommandFlags = function( command ) {
  describe("will error out if a bad flag is provided", function() {

    var opts1 = {
      testSpec: "-A",
      configFile: "commands/" + command + "-bad-flags-short",
      project: "basic",
      asserts: function(output, projectData, done) {
        expect(output.serr.indexOf("unknown option")).to.be.above(5);
        done();
      }
    };

    var opts2 = {
      testSpec: "--AAAAA",
      configFile: "commands/" + command + "-bad-flags-long",
      project: "basic",
      asserts: function(output, projectData, done) {
        expect(output.serr.indexOf("unknown option")).to.be.above(5);
        done();
      }
    }

    opts1[command + "Flags"] = "-A";
    opts2[command + "Flags"] = "--AAAAAA";

    spawn[command + "Test"](opts1);
    spawn[command + "Test"](opts2);
  });
};

// Ensures a command reacts to --help flag
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
        expect(loggerGreenSpy.callCount).to.be.above(0);
        expect(loggerBlueSpy.callCount).to.be.above(0);
        done()
        return program;
      };

      command( program );
    });
  })
};

// ensures a command handles when the profile
// flag is used but no profile is provided.
var missingProfile = function( command ) {
  var opts = {
    testSpec: "will error out if profile not provided",
    configFile: "commands/" + command + "-error-no-profile",
    project: "basic",
    asserts: function(output, projectData, done) {
      expect(output.serr.indexOf("argument missing")).to.be.above(30)
      done();
    }
  };

  opts[command + "Flags"] = "-P";
  spawn[command + "Test"](opts);
}


// Positive test to ensure a command can handle all the flags
// it is supposed to handle
var handlesFlags = function( command, flagsFull, flagsShort, asserts, fileSuccessCount ) {
  describe("is configured to accept the appropriate flags (will not error out)", function() {

    var opts1 = {
      testSpec: flagsShort,
      configFile: "commands/" + command + "-flags-short",
      project: "basic",
      asserts: asserts,
    };

    var opts2 = {
      testSpec: flagsFull,
      configFile: "commands/" + command + "-flags-long",
      project: "basic",
      asserts: asserts
    };

    if (fileSuccessCount) {
      opts1.fileSuccessCount = fileSuccessCount;
      opts2.fileSuccessCount = fileSuccessCount;
    }

    opts1[command + "Flags"] = flagsShort;
    opts2[command + "Flags"] = flagsFull;

    spawn[command + "Test"](opts1);
    spawn[command + "Test"](opts2);
  });
};

// ensures that when the debug flag is set for a command
// that the proper debugging is set up
var debugSetup = function( commandString, command ) {
  describe("when debug flag is ticked", function() {
    var cwd
      , projectData
      , loggerSpy
      , testOpts = {
        configFile: "commands/" + commandString + "-debug",
        project: "basic"
      };

    before(function() {
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );

      loggerSpy = sinon.spy(logger, "setDebug");

      var fakeProgram = utils.fakeProgram();
      fakeProgram.action = function( funct ) {
        funct( {mdebug: true} );
        return fakeProgram;
      }
      command( fakeProgram );
    });

    after(function() {
      utils.cleanProject( projectData );
      process.chdir(cwd);
      logger.setDebug.restore();
    });

    it("will set logger to debug mode", function() {
      expect(loggerSpy.calledOnce).to.be.true;
    })
    it("will set environment to debug mode", function() {
      expect(process.env.DEBUG).to.eql('true');
    })
  });
};

var removesDotMimosa = function( commandString, command ) {
  describe("when --cleanall flag ticked", function() {
    var cwd
      , projectData
      , commandFunct
      , nestedFile
      , mimosaFolder
      , testOpts = {
        configFile: "commands/" + commandString + "-remove-dot-mimosa",
        project: "basic"
      };

    before(function(){
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      fakeProgram = utils.fakeProgram();
      fakeProgram.action = function( funct ) {
        commandFunct = funct;
        return fakeProgram;
      };
      sinon.stub(process, "exit", function(){});

      // create folder
      mimosaFolder = path.join( projectData.projectDir, ".mimosa", "bower" );
      wrench.mkdirSyncRecursive( mimosaFolder );
      nestedFile = path.join( mimosaFolder, "foo.js" );
      fs.writeFileSync( nestedFile, "foo.js" );

      command( fakeProgram );
    });

    after(function() {
      utils.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
    });

    it("will remove .mimosa directory", function( done ) {
      expect(fs.existsSync(nestedFile)).to.be.true;
      expect(fs.existsSync(mimosaFolder)).to.be.true;

      commandFunct( {cleanall: true} );
      setTimeout( function() {
        expect(fs.existsSync(nestedFile)).to.be.false;
        expect(fs.existsSync(mimosaFolder)).to.be.false;
        done();
      }, 200);
    });

    it("will not error out if there is no .mimosa directory", function() {
      loggerSpy = sinon.spy(logger, "info");
      commandFunct( {cleanall: true} );
      expect(loggerSpy.calledWith("Removed .mimosa directory.")).to.be.true;
      logger.info.restore();
    });
  });
};

module.exports = {
  missingProfile: missingProfile,
  commandHelpTest: commandHelpTest,
  testBadCommandFlags: testBadCommandFlags,
  handlesFlags: handlesFlags,
  debugSetup: debugSetup,
  removesDotMimosa: removesDotMimosa
};
