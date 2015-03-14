var cp = require( 'child_process' )
  , path = require( "path" )
  , wrench = require( "wrench" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , commandPath = path.join( process.cwd(), "lib", "command", "module", "install")
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

describe("Mimosa's module install command", function() {

  // install from NPM
  describe("if name is provided", function() {

    describe("incorrectly", function() {
      it("will error out", function() {
        var logErrorStub = sinon.stub( logger, "error", function(){});
        executeCommand( "foo" );
        expect(logErrorStub.calledWith("Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server).")).to.be.true;
        logger.error.restore();
      });
    })

    describe("correctly", function(){

      before(function() {
        writeFileStub = sinon.stub(fs, "writeFileSync", function(){});
        cpdirStub = sinon.stub(wrench, "copyDirSyncRecursive", function() {});
        rmdirStub = sinon.stub(wrench, "rmdirSyncRecursive", function() {});
        chdirStub = sinon.stub(process, "chdir", function() {});
      });

      after(function() {
        wrench.copyDirSyncRecursive.restore();
        wrench.rmdirSyncRecursive.restore();
        fs.writeFileSync.restore();
        process.chdir.restore();
      });

      describe("will", function() {
        var name;

        before(function(done) {
          sinon.stub( cp, "exec", function(_name) {
            name = _name;
            done()
          });
          executeCommand( "mimosa-what");
        });

        after(function() {
          cp.exec.restore();
        })

        it("switch into appropriate directory for install (mimosa's root)", function() {
          expect(chdirStub.calledWith(process.cwd())).to.be.true;
        });

        it("attempt to install correct library/version if specific version provided", function() {
          expect(name).to.eql("npm install \"mimosa-what\" --save")
        });
      });

      describe("if package does not exist", function() {
        var library = "what";

        before(function(){
          sinon.stub(fs, "existsSync", function(){ return false; });
        });

        after(function() {
          fs.existsSync.restore();
        });

        describe("", function() {
          var execStub;

          before(function(done) {
            execStub = sinon.stub( cp, "exec", function(_name) {
              done();
            });
            executeCommand( "mimosa-" + library);
          });

          after(function() {
            cp.exec.restore();
          });

          it("will not back up the package before installing", function() {
            expect(cpdirStub.callCount).to.eql(0);
          });

          it("will not remove the dependency from the package.json before installing", function() {
            expect(writeFileStub.callCount).to.eql(0);
          });

          it("will attempt install", function() {
            expect(execStub.calledOnce).to.be.true;
            expect(execStub.args[0][0]).to.eql("npm install \"mimosa-what\" --save")
          });
        });

        describe("if error occurs during install", function(){

          before(function(done) {
            writeFileStub.reset()
            cpdirStub.reset();
            rmdirStub.reset();
            chdirStub.reset();
            sinon.stub( cp, "exec", function(_name, cb) {
              cb("ERROR", "", "");
            });
            sinon.stub(process, "exit", function() {
              done();
            })
            executeCommand( "mimosa-" + library);
          });

          after(function() {
            cp.exec.restore();
            process.exit.restore();
          });

          it("will not attempt to place backup back", function() {
            expect(cpdirStub.callCount === 0).to.be.true;
          });

          it("will not attemt to update package.json", function() {
            expect(writeFileStub.callCount === 0).to.be.true;
          });

          it("will not attempt to remove package backup", function() {
            expect(writeFileStub.callCount === 0).to.be.true;
          });

          it("will return to the original directory", function() {
            expect(chdirStub.calledTwice).to.be.true;
            expect(chdirStub.args[1][0]).to.eql(process.cwd());
          });
        });

        describe("if install is successful", function(){

          before(function(done) {
            rmdirStub.reset();
            chdirStub.reset();
            sinon.stub( cp, "exec", function(_name, cb) {
              cb(null, "", "");
            });
            sinon.stub(process, "exit", function() {
              done();
            })
            executeCommand( "mimosa-" + library);
          });

          after(function() {
            cp.exec.restore();
            process.exit.restore();
          });

          it("will not attempt to remove package backup", function() {
            expect(rmdirStub.callCount === 0).to.be.true;
          });

          it("will return to the original directory", function() {
            expect(chdirStub.calledTwice).to.be.true;
            expect(chdirStub.args[1][0]).to.eql(process.cwd());
          });
        });

      });

      describe("if package already exists", function(){
        var library = "copy";

        before(function(){
          sinon.stub(fs, "existsSync", function(){ return true; });
        });

        after(function() {
          fs.existsSync.restore();
        });

        describe("", function() {
          var execStub;

          before(function(done) {
            execStub = sinon.stub( cp, "exec", function(_name) {
              done();
            });
            executeCommand( "mimosa-" + library);
          });

          after(function() {
            cp.exec.restore();
          });

          it("will back up the package before installing", function() {
            expect(cpdirStub.calledOnce).to.be.true;
            var beginPath = path.join( process.cwd(), "node_modules", "mimosa-" + library );
            var endPath = path.join( process.cwd(), "node_modules", "mimosa-" + library + "_____backup" );
            expect(cpdirStub.args[0][0]).to.eql(beginPath)
            expect(cpdirStub.args[0][1]).to.eql(endPath)
          });

          it("will remove the dependency from the package.json before installing", function() {
            expect(writeFileStub.calledOnce).to.be.true;
            var packageJSON = JSON.parse(writeFileStub.args[0][1]);
            expect(Object.keys(packageJSON.dependencies).length).to.be.above(5)
            expect(packageJSON.dependencies["mimosa-" + library]).to.be.undefined
          });

          it("will attempt install", function() {
            expect(execStub.calledOnce).to.be.true;
            expect(execStub.args[0][0]).to.eql("npm install \"mimosa-copy\" --save")
          });
        });

        describe("if error occurs during install", function(){

          before(function(done) {
            writeFileStub.reset()
            cpdirStub.reset();
            rmdirStub.reset();
            chdirStub.reset();
            sinon.stub( cp, "exec", function(_name, cb) {
              cb("ERROR", "", "");
            });
            sinon.stub(process, "exit", function() {
              done();
            })
            executeCommand( "mimosa-" + library);
          });

          after(function() {
            cp.exec.restore();
            process.exit.restore();
          });

          it("will place backup back", function() {
            expect(cpdirStub.calledTwice).to.be.true;
            var beginPath = path.join( process.cwd(), "node_modules", "mimosa-" + library );
            var endPath = path.join( process.cwd(), "node_modules", "mimosa-" + library + "_____backup" );
            expect(cpdirStub.args[1][0]).to.eql(endPath)
            expect(cpdirStub.args[1][1]).to.eql(beginPath)
          });

          it("will update package.json back to where it was", function() {
            expect(writeFileStub.calledTwice).to.be.true;
            var packageJSON = JSON.parse(writeFileStub.args[1][1]);
            expect(Object.keys(packageJSON.dependencies).length).to.be.above(5)
            expect(typeof packageJSON.dependencies["mimosa-" + library]).to.eql('string');
          });

          it("will remove package backup", function() {
            expect(rmdirStub.calledOnce).to.be.true;
            var endPath = path.join( process.cwd(), "node_modules", "mimosa-" + library + "_____backup" );
            expect(rmdirStub.args[0][0]).to.eql(endPath);
          });

          it("will return to the original directory", function() {
            expect(chdirStub.calledTwice).to.be.true;
            expect(chdirStub.args[1][0]).to.eql(process.cwd());
          });
        });

        describe("if install is successful", function(){

          before(function(done) {
            rmdirStub.reset();
            chdirStub.reset();
            sinon.stub( cp, "exec", function(_name, cb) {
              cb(null, "", "");
            });
            sinon.stub(process, "exit", function() {
              done();
            })
            executeCommand( "mimosa-" + library);
          });

          after(function() {
            cp.exec.restore();
            process.exit.restore();
          });

          it("will remove package backup", function() {
            expect(rmdirStub.calledOnce).to.be.true;
            var endPath = path.join( process.cwd(), "node_modules", "mimosa-" + library + "_____backup" );
            expect(rmdirStub.args[0][0]).to.eql(endPath);
          });

          it("will return to the original directory", function() {
            expect(chdirStub.calledTwice).to.be.true;
            expect(chdirStub.args[1][0]).to.eql(process.cwd());
          });
        });
      });
    });
  });

  describe("if name is not provided will run local install", function() {
    var chdirStub
      , logErrorSpy
      , logSuccessSpy
      , currDir
      ;

    before(function() {
      currDir = process.cwd();
      process.chdir(path.join(process.cwd(), "node_modules", "mimosa-copy"))
      chdirStub = sinon.stub(process, "chdir", function() {});
      logErrorSpy = sinon.spy(logger, "error");
      logSuccessSpy = sinon.spy(logger, "success");
      sinon.stub(process, "exit", function() {});
    });

    after(function() {
      process.chdir(currDir);
      process.chdir.restore();
      logger.success.restore();
      logger.error.restore();
      process.exit.restore();
    });

    describe("if local install fails", function() {
      var execStub;

      before(function(done) {
        chdirStub.reset();
        logErrorSpy.reset();
        execStub = sinon.stub( cp, "exec", function(_name, cb) {
          cb("ERROR", null, null);
          setTimeout(done, 40)
        });
        executeCommand();
      });

      after(function() {
        cp.exec.restore();
      });

      it("will make npm install call", function() {
        expect(execStub.args[0][0]).to.eql("npm install")
      });

      it("will log error", function() {
        expect(logErrorSpy.args[0][0].indexOf("Could not install module locally")).to.eql(0);
      });

      it("will not chdir in order to install module", function() {
        expect(chdirStub.callCount === 0).to.be.true;
      });
    });

    describe("if local install succeeds", function() {
      var execStub;

      before(function(done) {
        chdirStub.reset();
        logSuccessSpy.reset();
        execStub = sinon.stub( cp, "exec", function(_name, cb) {
          if (execStub.callCount === 2) {
            setTimeout(done, 100);
          }

          cb(null, null, null);
        });
        executeCommand();
      });

      after(function() {
        cp.exec.restore();
      });

      it("will switch into mimosa directory", function(){
        expect(chdirStub.args[0][0]).to.eql(currDir);
      });

      it("will attempt npm install of local module into mimosa", function() {
        expect(execStub.calledTwice).to.be.true;
        expect(execStub.args[1][0]).to.eql("npm install \"" + process.cwd() + "\" --save")
      });

      describe("and mimosa install succeeds", function() {
        it("will log success", function() {
          expect(logSuccessSpy.calledOnce).to.be.true;
          expect(logSuccessSpy.args[0][0]).to.eql("Install of [[ " + process.cwd() + " ]] successful")
        });

        it("will switch back to orig directory", function() {
          expect(chdirStub.args[1][0]).to.eql(process.cwd())
        });
      });
    });

    describe("if local npm install fails", function() {
      var execStub
        , called = 0
        ;

      before(function(done) {
        chdirStub.reset();
        logErrorSpy.reset();
        execStub = sinon.stub( cp, "exec", function(_name, cb) {
          called++;
          console.log("CALLED", called)
          if (called === 2) {
            cb("ERROR", null, null);
            setTimeout(done, 100);
          } else {
            cb(null, null, null);
          }
        });
        executeCommand();
      });

      after(function() {
        cp.exec.restore();
      });

      it("will log error", function() {
        expect(logErrorSpy.args[0][0]).to.eql("Error installing module");
      });

      it("will return to original directory", function() {
        expect(chdirStub.args[1][0]).to.eql(process.cwd())
      });
    });
  });

  utils.test.command.flags.help( command );
  utils.test.command.flags.debugSetup( "modinstall", command, "foo" );
});