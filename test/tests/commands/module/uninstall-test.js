var cp = require( 'child_process' )
  , path = require( "path" )
  , wrench = require( "wrench" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , commandPath = path.join( process.cwd(), "lib", "command", "module", "uninstall")
  , command = require( commandPath )
  , utils = require( path.join(process.cwd(), "test", "utils"))
  ;

var executeCommand = function( val ) {
  var fakeProgram = utils.fake.program();
  fakeProgram.action = function( funct ) {
    funct( val, {} );
    return fakeProgram;
  }
  command( fakeProgram );
}

describe("Mimosa's mod:uninstall command", function() {
  var loggerErrorStub;

  before(function() {
    loggerErrorStub = sinon.stub( logger, "error", function(){})
  });

  after(function() {
    logger.error.restore();
  });


  describe("when run on local module", function() {
    describe("will error out", function() {

      beforeEach(function() {
        loggerErrorStub.reset();
      })

      it("when no local package.json", function() {
        sinon.stub(fs, "readFileSync", function() {
          throw new Error("error")
        });
        executeCommand();
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0].indexOf("Unable to find package.json, or badly formatted:") === 0).to.be.true;
        fs.readFileSync.restore();
      });

      it("when package.json has no name", function() {
        sinon.stub(fs, "readFileSync", function() {
          return "{\"version\":\"1.1.1\"}";
        });
        executeCommand();
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("package.json missing either name or version");
        fs.readFileSync.restore();
      });

      it("when package.json has no version", function() {
        sinon.stub(fs, "readFileSync", function() {
          return "{\"name\":\"foo\"}";
        });
        executeCommand();
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("package.json missing either name or version");
        fs.readFileSync.restore();
      });

      it("when name isn't prefixed with mimosa-", function() {
        sinon.stub(fs, "readFileSync", function() {
          return "{\"name\":\"foo\", \"version\":\"1.1.1\"}";
        });
        executeCommand();
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("Can only delete 'mimosa-' prefixed modules with mod:uninstall (ex: mimosa-server).");
        fs.readFileSync.restore();
      });

      it("if module not currently installed in mimosa", function() {

      });
    });

    describe("will attempt install", function() {
      it("from the mimosa directory")
      it("with proper install string")
      describe("when successful", function() {
        it("will return to the original directory")
        it("will log success")
      });
      describe("when failure", function() {
        it("will return to the original directory")
        it("will log error")
      });
    });
  })

  describe("when run on named module", function() {
    describe("will error out", function() {
      it("when name isn't prefixed with mimosa-")
      it("if module not currently installed in mimosa")
    });

    describe("will attempt install", function() {
      it("from the mimosa directory")
      it("with proper install string")
      describe("when successful", function() {
        it("will return to the original directory")
        it("will log success")
      });
      describe("when failure", function() {
        it("will return to the original directory")
        it("will log error")
      });
    });
  });

  utils.test.command.flags.help( command );
  utils.test.command.flags.debugSetup( "moduninstall", command, "foo" );

})