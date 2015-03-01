var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , wrench = require( "wrench" )
  , logger = require( "logmimosa" )
  , cleanCommandPath = path.join( process.cwd(), "lib", "command", "clean" )
  , cleanCommand = require( cleanCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's clean command", function() {

  utils.test.command.spawn.clean({
    testSpec: "will error out if profile not provided",
    configFile: "commands/clean-error-no-profile",
    project: "basic",
    cleanFlags:"-P",
    asserts: function(output, projectData, done) {
      expect(output.serr.indexOf("argument missing")).to.be.above(30)
      done();
    }
  });

  describe("is configured to accept the appropriate flags (will not error out)", function() {
    utils.test.command.spawn.clean({
      testSpec: "-fCD",
      configFile: "commands/clean-flags-short",
      project: "basic",
      cleanFlags:"-fCD",
      asserts: function(output, projectData, done) {
        expect(output.sout.substring(output.sout.length-17)).to.eql(" already deleted\n")
        done();
      }
    });

    utils.test.command.spawn.clean({
      testSpec: "--force --cleanall --mdebug",
      configFile: "commands/clean-flags-long",
      project: "basic",
      cleanFlags:"--force --cleanall --mdebug",
      asserts: function(output, projectData, done) {
        expect(output.sout.substring(output.sout.length-17)).to.eql(" already deleted\n")
        done();
      }
    });

  });

  describe("will error out if a bad flag is provided", function() {
    utils.test.command.spawn.clean({
      testSpec: "-g",
      configFile: "commands/clean-bad-flags-short",
      project: "basic",
      cleanFlags:"-g",
      asserts: function(output, projectData, done) {
        expect(output.serr.indexOf("unknown option")).to.be.above(5)
        done();
      }
    });


    utils.test.command.spawn.clean({
      testSpec: "--foo",
      configFile: "commands/clean-bad-flags-long",
      project: "basic",
      cleanFlags:"--foo",
      asserts: function(output, projectData, done) {
        expect(output.serr.indexOf("unknown option")).to.be.above(5)
        done();
      }
    });
  });

});