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
      logger.setDebug.restore();
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
      , loggerSpy = sinon.spy(logger, "success")
      , testOpts = {
        configFile: "commands/build-command",
        project: "basic"
      };

    before(function(done){
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
      buildCommand( fakeProgram );
      setTimeout(function(){
        done();
      }, 200)
    });

    after(function() {
      utils.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
      logger.success.restore();
    });

    it("to the output directory", function(done){
      var filesAndFolders = utils.filesAndDirsInFolder(projectData.publicDir)
      expect( filesAndFolders ).to.eql(11);
      done();
    });

    it("and will print success message when done", function() {
      expect(loggerSpy.args[loggerSpy.args.length - 1][0]).to.eql("Finished build");
    });

  });

  describe("when --cleanall flag ticked", function() {
    var cwd
      , projectData
      , buildFunct
      , nestedFile
      , mimosaFolder
      , testOpts = {
        configFile: "commands/build-remove-dot-mimosa",
        project: "basic"
      };

    before(function(){
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      fakeProgram = utils.fakeProgram();
      fakeProgram.action = function( funct ) {
        buildFunct = funct;
        return fakeProgram;
      };
      var processExitStub = sinon.stub(process, "exit", function(){});

      // create folder
      mimosaFolder = path.join( projectData.projectDir, ".mimosa", "bower" );
      wrench.mkdirSyncRecursive( mimosaFolder );
      nestedFile = path.join( mimosaFolder, "foo.js" );
      fs.writeFileSync( nestedFile, "foo.js" );

      buildCommand( fakeProgram );
    });

    after(function() {
      utils.cleanProject( projectData );
      process.chdir(cwd);
      process.exit.restore();
    });

    it("will remove .mimosa directory", function( done ) {
      expect(fs.existsSync(nestedFile)).to.be.true;
      expect(fs.existsSync(mimosaFolder)).to.be.true;

      buildFunct( {cleanall: true} );
      setTimeout( function() {
        expect(fs.existsSync(nestedFile)).to.be.false;
        expect(fs.existsSync(mimosaFolder)).to.be.false;
        done();
      }, 200);
    });

    it("will not error out if there is no .mimosa directory", function() {
      loggerSpy = sinon.spy(logger, "info");
      buildFunct( {cleanall: true} );
      expect(loggerSpy.calledWith("Removed .mimosa directory.")).to.be.true;
      logger.info.restore();
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
      projectData = utils.setupProjectData( testOpts.configFile );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, testOpts.project );
      cwd = process.cwd();
      process.chdir( projectData.projectDir );
      fakeProgram = utils.fakeProgram();
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
      utils.cleanProject( projectData );
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

  it("will error out if profile not provided")

  describe("is configured to accept the appropriate flags (will not error out)", function() {
    it("-ompieCDP foo");
    it("--optimize --minify --package --install --errorout --cleanall --mdebug --profile foo")
  });

  describe("will error out if a bad flag is provided", function() {
    it("-f");
    it("--foo");
  });

});
