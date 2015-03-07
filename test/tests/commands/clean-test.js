var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , cleanCommandPath = path.join( process.cwd(), "lib", "command", "clean" )
  , cleanCommand = require( cleanCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's clean command", function() {

  describe("will clean files", function() {
    var cwd
      , projectData
      , fakeProgram
      , extraFile
      , testOpts = {
        configFile: "commands/clean",
        project: "basic-built"
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

    it("if the files are present in output directory", function(done) {
      var loggerSpy = sinon.spy(logger, "success")
      cleanCommand( fakeProgram );
      setTimeout(function() {
        var calledWithAll = loggerSpy.args.map(function(args){
          return args[0];
        });
        var deletedFiles = calledWithAll.filter(function(calledWith){
          return /^Deleted file/.test(calledWith);
        });
        var deletedFolders = calledWithAll.filter(function(calledWith){
          return /^Deleted empty directory/.test(calledWith);
        });

        expect(deletedFiles.length).to.eql(5);
        expect(deletedFolders.length).to.eql(5);

        logger.success.restore();
        done();
      }, 150)
    });

    it("but not any files it does not know about", function() {
      expect(fs.existsSync(extraFile)).to.be.true;
    });
  });

  describe("will force clean files", function() {
    var cwd
      , projectData
      , fakeProgram
      , extraFile
      , loggerSpy
      , testOpts = {
        configFile: "commands/clean-no-output",
        project: "basic-built"
      };

    before(function() {
      projectData = utils.setup.projectData( testOpts.configFile );
      utils.setup.cleanProject( projectData );
      utils.setup.project( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      fakeProgram = utils.fake.program();
      fakeProgram.action = function( funct ) {
        funct( {force:true} );
        return fakeProgram;
      }
      var processExitStub = sinon.stub(process, "exit", function(){});
      loggerSpy = sinon.spy(logger, "success")
    });

    afterEach(function() {
      loggerSpy.reset();
    });

    after(function() {
      utils.setup.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
      logger.success.restore()
    });

    it("when there is an output directory", function(done) {
      cleanCommand( fakeProgram );
      setTimeout(function() {
        var calledWithAll = loggerSpy.args.map(function(args){
          return args[0];
        });
        var deleted = calledWithAll.filter(function(calledWith){
          return /has been removed/.test(calledWith);
        });

        expect(deleted.length).to.eql(1);
        done();
      }, 150)
    });

    describe("", function() {
      it("but not break when there isn't an output directory", function(done){
        cleanCommand( fakeProgram );
        setTimeout(function() {
          var calledSuccess = loggerSpy.args.map(function(args){
            return args[0];
          });

          expect(calledSuccess.length).to.eql(1);
          expect(calledSuccess[0].indexOf("Compiled directory already deleted")).to.eql(0);
          done();
        }, 150)
      });
    });
  });

  utils.test.command.flags.removesDotMimosa( "clean", cleanCommand );
  utils.test.command.flags.debugSetup( "clean", cleanCommand );
  utils.test.command.flags.missingProfile( "clean" )
  utils.test.command.flags.handlesFlags(
    "clean",
    "--force --cleanall --mdebug",
    "-fCD",
    function(output, projectData, done) {
      expect(output.sout.substring(output.sout.length-17)).to.eql(" already deleted\n")
      done();
    }
  );
  utils.test.command.flags.invalid("clean");
  utils.test.command.flags.help( cleanCommand );

});