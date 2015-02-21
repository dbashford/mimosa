var path = require( "path" )
  , logger = require( "logmimosa")
  , sinon = require( "sinon" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's build command", function() {

  it("will print help", function( done ) {
    var loggerGreenSpy = sinon.spy(logger, "green");
    var loggerBlueSpy = sinon.spy(logger, "blue");

    after(function(){
      loggerGreenSpy.reset();
      loggerBlueSpy.reset();
    });

    var program = {
      on: function(flag, cb) {
        expect(flag).to.eql("--help");
        cb();
        expect(loggerGreenSpy.callCount).to.be.above(10);
        expect(loggerBlueSpy.callCount).to.be.above(10);
        done()
        return program;
      },
      command: function(){ return program },
      description: function(){ return program },
      command: function(){return program },
      option: function(){return program },
      action: function(){ return program }
    }
    buildCommand( program );

  });

  describe("will set proper config flags", function() {
    it("--optimize");
    it("-o");
    it("--minify");
    it("-m");
    it("--package");
    it("-p");
    it("--install");
    it("-i");
    it("--errorout");
    it("-e")
    it("--cleanall");
    it("-C");
    it("--mdebug");
    it("-D");
    it("-ompieCDP foo");
    it("--optimize --minify --package --install --errorout --cleanall --mdebug --profile foo")
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
