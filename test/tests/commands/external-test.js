var spawn = require('child_process').spawn
  , path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , externalCommandPath = path.join( process.cwd(), "lib", "command", "external" )
  , externalCommand = require( externalCommandPath )
  , utils = require( "../../utils" )
  , modulesPath = path.join( process.cwd(), "lib", "modules" )
  , moduleCentral = require( modulesPath )
  ;

describe("Mimosa's external command registration", function() {

  describe("calls the registerCommand function", function() {
    var registerSpy;

    before(function() {
      registerSpy = sinon.spy();
      var fakeModuleWithCommand1 = { registerCommand: registerSpy };
      var fakeModuleWithCommand2 = { registerCommand: registerSpy };
      var modulesWithCommandsStub = sinon.stub( moduleCentral, "modulesWithCommands", function() {
        return [fakeModuleWithCommand1, fakeModuleWithCommand2];
      });
    });

    after( function() {
      moduleCentral.modulesWithCommands.restore();
    });

    it("of modules that expose it", function() {
      externalCommand( function(){} )
      expect(registerSpy.calledTwice).to.be.true;
    });
  });

  describe("when its retrieveConfig callback is executed", function() {
    var retrieveConfig
      , loggerSpy
      ;

    before(function() {
      var fakeModuleWithCommand = {
        registerCommand: function(program, logger, _retrieveConfig) {
          retrieveConfig = _retrieveConfig
        }
      };
      var modulesWithCommandsStub = sinon.stub( moduleCentral, "modulesWithCommands", function() {
        return [fakeModuleWithCommand];
      });
      loggerSpy = sinon.spy(logger, "setDebug");
      externalCommand( function(){} );
    });

    after( function() {
      moduleCentral.modulesWithCommands.restore();
      logger.setDebug.restore();
    });

    it("will allow mimosa to be put into debug mode", function(done) {
      var opts = {
        mdebug: true
      };
      retrieveConfig( opts, function() {
        expect(loggerSpy.calledOnce).to.be.true;
        done()
      });
    });

    it("will process and pass back configuration", function(done) {
      var opts = {};
      retrieveConfig( opts, function( config ) {
        expect(config).to.be.object;
        expect(config.root).to.eql(process.cwd())
        done();
      });
    });

    it("will accept other flags", function(done) {
      var opts = {
        errorout: true
      };
      retrieveConfig( opts, function( config ) {
        expect(config.exitOnError).to.be.true;
        done();
      });
    });

    it("will return config when buildFirst set to false", function(done) {
      var opts = {
        buildFirst: false
      };
      retrieveConfig( opts, function( config ) {
        expect(config).to.be.object;
        expect(config.root).to.eql(process.cwd())
        done();
      });
    });

  });

  // no spawn tests on travis
  if (__dirname.indexOf("/travis/") === -1) {
    describe("will clean and build the application, then pass config", function() {
      var cwd
        , projectData
        , testOpts = {
          configFile: "external/build-first",
          project: "basic-with-command-module"
        }
        ;

      before(function() {
        projectData = utils.setup.projectData( testOpts.configFile );
        utils.setup.cleanProject( projectData );
        utils.setup.project( projectData, testOpts.project );
        cwd = process.cwd();
        process.chdir( projectData.projectDir );

      });

      after(function() {
        utils.setup.cleanProject( projectData );
        process.chdir(cwd);
      });

      it("when buildFirst is true", function(done) {
        var mimosaProc = spawn( 'mimosa', ['custom'] )
          , data = "";
        mimosaProc.stdout.on( 'data', function ( _data ) {
          data += _data.toString();
        });
        mimosaProc.on('exit', function() {
          expect(data.match(/Wrote file/g).length).to.eql(5);
          var lines = data.split("\n");
          var lastLine = lines[lines.length -2]
          expect(/THIS IS AFTER THE BUILD$/.test(lastLine)).to.be.true;
          done();
        });
      });
    });
  }


});