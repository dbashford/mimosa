var path = require( "path" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's build command", function() {
  var cwd
    , testOpts = {
      configFile: "commands/build-no-flags",
      project: "basic"
    };

  before(function(){
    projectData = utils.setupProjectData( testOpts.configFile );
    utils.cleanProject( projectData );
    utils.setupProject( projectData, testOpts.project );
    cwd = process.cwd();
    process.chdir( projectData.projectDir );
  });

  after(function(){
    utils.cleanProject( projectData );
    process.chdir(cwd);
  });

  it("will build files");

  describe("when --cleanall flag ticked", function() {
    it("will remove .mimosa directory");
    it("will not error out if there is no .mimosa directory")
  });

  describe("will first clean files", function() {
    it("before building if the files are present in output directory");
    it("but not any files it does not know about");
  });

  describe("is configured to accept the appropriate flags (will not error out)", function() {
    it("-ompieCDP foo");
    it("--optimize --minify --package --install --errorout --cleanall --mdebug --profile foo")
  });

  describe("will error out if a bad flag is provided", function() {
    it("-f");
    it("--foo");
  });

  it("will error out if profile not provided")

  it("will print success message when done");

});
