var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , watchCommandPath = path.join( process.cwd(), "lib", "command", "watch" )
  , watchCommand = require( watchCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's watch command", function() {

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
      fakeProgram = utils.fake.program();
      fakeProgram.action = function( funct ) {
        funct( {} );
        return fakeProgram;
      };
      watchCommand( fakeProgram );
      setTimeout(function(){
        process.emit("STOPMIMOSA")
        done();
      }, 200)
    });

    after(function() {
      utils.setup.cleanProject( projectData );
      process.chdir(cwd);
      logger.success.restore();
    });

    it("to the output directory", function(done){
      var filesAndFolders = utils.util.filesAndDirsInFolder(projectData.publicDir)
      expect( filesAndFolders ).to.eql(11);
      done();
    });

    it("and will print success messages for files", function() {
      var calledWithAll = loggerSpy.args.map(function(args){
        return args[0];
      });
      var writtenFiles = calledWithAll.filter(function(calledWith){
        return /^Wrote file/.test(calledWith)
      });
      expect(writtenFiles.length).to.eql(5)
    });
  });

  utils.test.command.flags.removesDotMimosa( "watch", watchCommand );
  utils.test.command.flags.debugSetup( "watch", watchCommand );
  utils.test.command.flags.missingProfile( "watch" )
  utils.test.command.flags.invalid("watch");
  utils.test.command.flags.handlesFlags(
    "watch",
    "--server --optimize --minify --clean --cleanall --delete --mdebug",
    "-somcCdD",
    function(output, projectData, done) {
      var successes = output.sout.match( /Wrote file/g );
      // 5 files written as part of test
      expect(successes.length).to.eql(5)
      done();
    },
    5
  );

});