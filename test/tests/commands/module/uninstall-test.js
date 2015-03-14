var cp = require( 'child_process' )
  , path = require( "path" )
  , wrench = require( "wrench" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , modulePath = path.join(process.cwd(), "lib", "modules")
  , moduleMetadata = require(modulePath).installedMetadata
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
  var loggerErrorStub
    , chdirStub
    ;

  before(function() {
    loggerErrorStub = sinon.stub( logger, "error", function(){});
    chdirStub = sinon.stub(process, "chdir", function(){});
  });

  after(function() {
    logger.error.restore();
    process.chdir.restore();
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
        require(modulePath).installedMetadata = [{name:"mimosa-foo"}];
        sinon.stub(fs, "readFileSync", function() {
          return "{\"name\":\"mimosa-require\", \"version\":\"1.1.1\"}";
        });
        executeCommand();
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("Module named [[ mimosa-require ]] is not currently installed so it cannot be uninstalled.");
        require(modulePath).installedMetadata = moduleMetadata;
        fs.readFileSync.restore();

      });

    });

    describe("will attempt install", function() {
      var execStub,
        loggerSuccessStub
        ;

      before(function( done ) {
        loggerSuccessStub = sinon.stub( logger, "success", function(){});
        require(modulePath).installedMetadata = [{name:"mimosa-require"}];
        sinon.stub(fs, "readFileSync", function() {
          return "{\"name\":\"mimosa-require\", \"version\":\"1.1.1\"}";
        });
        execStub = sinon.stub(cp, "exec", function( installPath, cb) {
          cb( null, null, null )
        });
        sinon.stub(process, "exit", function() {
          done();
        })
        executeCommand();
      });

      after(function() {
        require(modulePath).installedMetadata = moduleMetadata;
        fs.readFileSync.restore();
        cp.exec.restore();
        process.exit.restore();
        logger.success.restore();
      });

      it("from the mimosa directory", function() {
        expect(chdirStub.args[0][0]).to.eql(process.cwd())
      });

      it("with proper install string", function() {
        expect(execStub.args[0][0]).to.eql("npm uninstall \"mimosa-require\" --save")
      });

      describe("when successful", function() {
        it("will return to the original directory", function() {
          expect(chdirStub.args[1][0]).to.eql(process.cwd())
        });
        it("will log success", function() {
          expect(loggerSuccessStub.calledOnce).to.be.true;
          expect(loggerSuccessStub.args[0][0]).to.eql("Uninstall of [[ mimosa-require ]] successful")
        });
      });
    });

    describe("when install fails", function() {
      var execStub;

      before(function( done ) {
        loggerErrorStub.reset();
        require(modulePath).installedMetadata = [{name:"mimosa-require"}];
        sinon.stub(fs, "readFileSync", function() {
          return "{\"name\":\"mimosa-require\", \"version\":\"1.1.1\"}";
        });
        execStub = sinon.stub(cp, "exec", function( installPath, cb) {
          cb( "ERROR", null, null )
        });
        sinon.stub(process, "exit", function() {
          done();
        })
        executeCommand();
      });

      after(function() {
        require(modulePath).installedMetadata = moduleMetadata;
        fs.readFileSync.restore();
        cp.exec.restore();
        process.exit.restore();
      })

      it("will return to the original directory", function() {
        expect(chdirStub.args[1][0]).to.eql(process.cwd())
      });

      it("will log error", function() {
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("ERROR")
      });
    });
  })

  describe("when run on named module", function() {
    describe("will error out", function() {
      beforeEach(function() {
        loggerErrorStub.reset();
      })

      it("when name isn't prefixed with mimosa-", function() {
        it("when name isn't prefixed with mimosa-", function() {
          executeCommand("foo");
          expect(loggerErrorStub.calledOnce).to.be.true;
          expect(loggerErrorStub.args[0][0]).to.eql("Can only delete 'mimosa-' prefixed modules with mod:uninstall (ex: mimosa-server).");
        });
      })
      it("if module not currently installed in mimosa", function() {
        require(modulePath).installedMetadata = [{name:"mimosa-foo"}];
        executeCommand("mimosa-bar");
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("Module named [[ mimosa-bar ]] is not currently installed so it cannot be uninstalled.");
        require(modulePath).installedMetadata = moduleMetadata;
      })
    });

    describe("will attempt install", function() {

      var execStub,
        loggerSuccessStub
        ;

      before(function( done ) {
        chdirStub.reset();
        loggerSuccessStub = sinon.stub( logger, "success", function(){});
        require(modulePath).installedMetadata = [{name:"mimosa-foo"}];
        execStub = sinon.stub(cp, "exec", function( installPath, cb) {
          cb( null, null, null )
        });
        sinon.stub(process, "exit", function() {
          done();
        })
        executeCommand( "mimosa-foo" );
      });

      after(function() {
        require(modulePath).installedMetadata = moduleMetadata;
        cp.exec.restore();
        process.exit.restore();
        logger.success.restore();
      });

      it("from the mimosa directory", function() {
        expect(chdirStub.args[0][0]).to.eql(process.cwd());
      });

      it("with proper install string", function() {
        expect(execStub.args[0][0]).to.eql("npm uninstall \"mimosa-foo\" --save")
      });

      describe("when successful", function() {
        it("will return to the original directory", function() {
          expect(chdirStub.args[1][0]).to.eql(process.cwd());
        });

        it("will log success", function() {
          expect(loggerSuccessStub.calledOnce).to.be.true;
          expect(loggerSuccessStub.args[0][0]).to.eql("Uninstall of [[ mimosa-foo ]] successful")
        });
      });
    });

    describe("when install fails failure", function() {
      var execStub;

      before(function( done ) {
        loggerErrorStub.reset();
        require(modulePath).installedMetadata = [{name:"mimosa-foo"}];
        execStub = sinon.stub(cp, "exec", function( installPath, cb) {
          cb( "ERROR", null, null )
        });
        sinon.stub(process, "exit", function() {
          done();
        })
        executeCommand( "mimosa-foo" );
      });

      after(function() {
        require(modulePath).installedMetadata = moduleMetadata;
        cp.exec.restore();
        process.exit.restore();
      });

      it("will return to the original directory", function() {
        expect(chdirStub.args[1][0]).to.eql(process.cwd());
      });

      it("will log error", function() {
        expect(loggerErrorStub.calledOnce).to.be.true;
        expect(loggerErrorStub.args[0][0]).to.eql("ERROR")
      });
    });
  });

  utils.test.command.flags.help( command );
  utils.test.command.flags.debugSetup( "moduninstall", command, "foo" );

})