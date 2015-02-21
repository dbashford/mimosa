var path = require( "path" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's build command", function() {

  it("will print help");

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
