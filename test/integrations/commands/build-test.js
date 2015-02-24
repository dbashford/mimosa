var path = require( "path" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's build command", function() {

  describe("when debug flag is ticked", function() {
    var cwd
      , projectData
      , loggerSpy
      , testOpts = {
        configFile: "commands/build-debug",
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
      buildCommand( fakeProgram );
    });

    after(function() {
      utils.cleanProject( projectData );
      process.chdir(cwd);
    });

    it("will set logger to debug mode", function() {
      expect(loggerSpy.calledOnce).to.be.true;
    })
    it("will set environment to debug mode", function() {
      expect(process.env.DEBUG).to.eql('true');
    })
  });

  describe("will build files", function( ) {
    var cwd
      , projectData
      , fakeProgram
      , testOpts = {
        configFile: "commands/build-command",
        project: "basic"
      };

    before(function(){
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      var processExitStub = sinon.stub(process, "exit", function(){});
      fakeProgram = utils.fakeProgram();
      fakeProgram.action = function( funct ) {
        funct( {} );
        return fakeProgram;
      };
    });

    after(function() {
      utils.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
    });

    it("to the output directory", function(done){
      buildCommand( fakeProgram );
      setTimeout(function() {
        var filesAndFolders = utils.filesAndDirsInFolder(projectData.publicDir)
        expect( filesAndFolders ).to.eql(11);
        done();
      }, 300);
    });

  });

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
