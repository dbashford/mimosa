var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , watchCommandPath = path.join( process.cwd(), "lib", "command", "watch" )
  , watchCommand = require( watchCommandPath )
  , utils = require( "../../utils" )
  ;

var willBuildFiles = function( testOpts ) {

  var spec = (testOpts.spec | "") + "will build files";

  describe(spec, function( ) {
    var cwd
      , projectData
      , fakeProgram
      , loggerSpy
      ;

    before(function(done){
      loggerSpy = sinon.spy(logger, "success")
      projectData = utils.setup.projectData( testOpts.configFile );
      utils.setup.cleanProject( projectData );
      utils.setup.project( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      fakeProgram = utils.fake.program();
      fakeProgram.action = function( funct ) {
        var flags = testOpts.flags || {};
        funct( flags );
        return fakeProgram;
      };
      watchCommand( fakeProgram );
      if (!testOpts.noBuildTests) {
        setTimeout(function(){
          process.emit("STOPMIMOSA")
          done();
        }, 200)
      } else {
        done();
      }
    });

    after(function() {
      utils.setup.cleanProject( projectData );
      process.chdir(cwd);
      logger.success.restore();
    });

    // test flags?
    if (testOpts.flagTest) {
      it("", function() {
        testOpts.flagTest(projectData, loggerSpy);
      })
    }

    // don't want to test build, just testing flags
    if (!testOpts.noBuildTests) {
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
    }
  });
};


describe("Mimosa's watch command", function() {

  willBuildFiles({
    configFile: "commands/watch-command",
    project: "basic"
  });

  describe("when the delete flag is ticked", function() {
    var chokidarStub;

    var flagTest = function(projectData, loggerSpy) {
      var calledWithAll = loggerSpy.args.map(function(args){
        return args[0];
      });
      var removedDir = calledWithAll.filter(function(calledWith){
        return /has been removed$/.test(calledWith)
      });
      expect(removedDir.length).to.eql(1)
      expect(chokidarStub.calledOnce).to.be.true;
      expect(fs.existsSync(projectData.publicDir)).to.be.false;
    }

    before(function(){
      chokidarStub = utils.util.stubChokidar();
    });

    after(function(){
      utils.util.restoreChokidar();
    });

    afterEach(function() {
      chokidarStub.reset();
    })

    willBuildFiles({
      configFile: "commands/watch-command-delete-flag",
      project: "basic-built",
      spec:"will remove the compiled folder and continue watching/building",
      noBuildTests : true,
      flags: {
        delete:true
      },
      flagTest: flagTest
    });

    willBuildFiles({
      configFile: "commands/watch-command-delete-flag-dir-missing",
      project: "basic",
      spec:"will handle the compiled folder not being there at the outset and continue watching/building",
      noBuildTests : true,
      flags: {
        delete:true
      },
      flagTest: flagTest
    });

  });

  var cleanFlagTest = function(projectData, loggerSpy) {
    var calledWithAll = loggerSpy.args.map(function(args){
      return args[0];
    });
    var removedDir = calledWithAll.filter(function(calledWith){
      return /Deleted empty directory/.test(calledWith)
    });
    var removedFile = calledWithAll.filter(function(calledWith){
      return /Deleted file/.test(calledWith)
    });
    var wroteFile = calledWithAll.filter(function(calledWith){
      return /Wrote file/.test(calledWith)
    });

    expect(removedDir.length).to.eql(6);
    expect(removedFile.length).to.eql(5)
    expect(wroteFile.length).to.eql(5)
  }

  describe("when the clean flag is ticked", function() {
    willBuildFiles({
      configFile: "commands/watch-command-clean-flag",
      project: "basic-built",
      spec:"will clean and then watch the app",
      flags: {
        clean:true
      },
      flagTest: cleanFlagTest
    });
  });

  // TODO: test when needsClean flag is ticked, somehow.
  // describe("when the config.needsClean flag is ticked", function() {
  //   willBuildFiles({
  //     configFile: "commands/watch-command-clean-option",
  //     project: "basic-built",
  //     spec:"will clean and then watch the app",
  //     flags: {
  //       clean:true
  //     },
  //     flagTest: cleanFlagTest
  //   });
  // });

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
  utils.test.command.flags.help( watchCommand );

});