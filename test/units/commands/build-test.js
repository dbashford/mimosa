var path = require( "path" )
  , logger = require( "logmimosa")
  , sinon = require( "sinon" )
  , utils = require( "../../utils" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  ;

describe("Mimosa's build command", function() {

  it("will print help", function( done ) {
    var loggerGreenSpy = sinon.spy(logger, "green");
    var loggerBlueSpy = sinon.spy(logger, "blue");

    after(function(){
      loggerGreenSpy.reset();
      loggerBlueSpy.reset();
    });

    var program = utils.fakeProgram();
    program.on = function(flag, cb) {
      expect(flag).to.eql("--help");
      cb();
      expect(loggerGreenSpy.callCount).to.be.above(10);
      expect(loggerBlueSpy.callCount).to.be.above(10);
      done()
      return program;
    };

    buildCommand( program );
  });

  describe("when debug flag is ticked", function() {
    it("will set logger to debug mode")
    it("will set environment to debug mode")
  });

  describe("will pass proper config", function() {
    it("to the watcher");
    it("to the cleaner");
  });



});
