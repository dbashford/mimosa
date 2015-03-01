var sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , spawn = require("./spawn")
  , utils = require("../utils")
  ;

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

var handlesFlags = function( command, flagsFull, flagsShort, asserts ) {
  describe("is configured to accept the appropriate flags (will not error out)", function() {

    var opts1 = {
      testSpec: flagsShort,
      configFile: "commands/" + command + "-flags-short",
      project: "basic",
      buildFlags:"-ompieCD",
      asserts: asserts
    };

    var opts2 = {
      testSpec: flagsFull,
      configFile: "commands/" + command + "-flags-long",
      project: "basic",
      buildFlags:"--optimize --minify --package --install --errorout --cleanall --mdebug",
      asserts: asserts
    };

    opts1[command + "Flags"] = flagsShort;
    opts2[command + "Flags"] = flagsFull;

    spawn[command + "Test"](opts1);
    spawn[command + "Test"](opts2);
  });
}


module.exports = {
  missingProfile: missingProfile,
  commandHelpTest: commandHelpTest,
  testBadCommandFlags: testBadCommandFlags,
  handlesFlags: handlesFlags
};
