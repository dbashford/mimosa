var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , wrench = require( "wrench" )
  , logger = require( "logmimosa" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's build command", function() {

  describe("will build files", function( ) {
    var cwd
      , projectData
      , fakeProgram
      , loggerSpy
      , testOpts = {
        configFile: "commands/build-command",
        project: "basic"
      };

    before(function(done){
      loggerSpy = sinon.spy(logger, "success")
      projectData = utils.setup.projectData( testOpts.configFile );
      utils.setup.cleanProject( projectData );
      utils.setup.project( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      var processExitStub = sinon.stub(process, "exit", function(){});
      fakeProgram = utils.fake.program();
      fakeProgram.action = function( funct ) {
        funct( {} );
        return fakeProgram;
      };
      buildCommand( fakeProgram );
      setTimeout(function(){
        done();
      }, 200)
    });

    after(function() {
      utils.setup.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
      logger.success.restore();
    });

    it("to the output directory", function(done){
      var filesAndFolders = utils.util.filesAndDirsInFolder(projectData.publicDir)
      expect( filesAndFolders ).to.eql(11);
      done();
    });

    it("and will print success message when done", function() {
      expect(loggerSpy.args[loggerSpy.args.length - 1][0]).to.eql("Finished build");
    });

  });

  describe("will first clean files", function() {
    var cwd
      , projectData
      , fakeProgram
      , extraFile
      , testOpts = {
        configFile: "commands/build-clean",
        project: "basic"
      };

    before(function(done) {
      projectData = utils.setup.projectData( testOpts.configFile );
      utils.setup.cleanProject( projectData );
      utils.setup.project( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      fakeProgram = utils.fake.program();
      fakeProgram.action = function( funct ) {
        funct( {} );
        return fakeProgram;
      }
      var processExitStub = sinon.stub(process, "exit", function(){});

      buildCommand( fakeProgram );
      setTimeout(function() {
        extraFile = path.join( projectData.javascriptOutDir, "extra.js" );
        fs.writeFileSync( extraFile, "extra.js" )
        done();
      }, 150)
    });

    after(function() {
      utils.setup.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
    });

    it("before building if the files are present in output directory", function(done) {
      var loggerSpy = sinon.spy(logger, "success")
      buildCommand( fakeProgram );
      setTimeout(function() {
        var calledWithAll = loggerSpy.args.map(function(args){
          return args[0];
        });
        var deletedFiles = calledWithAll.filter(function(calledWith){
          return /^Deleted file/.test(calledWith)
        });
        var deletedFolders = calledWithAll.filter(function(calledWith){
          return /^Deleted empty directory/.test(calledWith)
        });

        expect(deletedFiles.length).to.eql(5)
        expect(deletedFolders.length).to.eql(5)

        logger.success.restore();
        done()
      }, 150)
    });

    it("but not any files it does not know about", function() {
      expect(fs.existsSync(extraFile)).to.be.true;
    });
  });

  utils.test.command.flags.removesDotMimosa( "build", buildCommand );
  utils.test.command.flags.debugSetup( "build", buildCommand );
  utils.test.command.flags.missingProfile( "build" );
  utils.test.command.flags.handlesFlags(
    "build",
    "--optimize --minify --package --install --errorout --cleanall --mdebug",
    "-ompieCD",
    function(output, projectData, done) {
      expect(output.sout.indexOf("Finished build")).to.be.above(1000)
      done();
    }
  );
  utils.test.command.flags.invalid("build");
  utils.test.command.flags.help( buildCommand );

});
