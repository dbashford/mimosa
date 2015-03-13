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
    it("will error out if name is not prefixed with mimosa-", function() {
      var logErrorStub = sinon.stub( logger, "error", function(){});
      executeCommand( "foo" );
      expect(logErrorStub.calledWith("Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server).")).to.be.true;
      logger.error.restore();
    });

    describe("correctly", function(){

      describe("will", function() {
        var name
          , chdirStub;

        before(function(done) {
          chdirStub = sinon.stub(process, "chdir", function() {});
          sinon.stub( cp, "exec", function(_name) {
            name = _name;
            done()
          });
          executeCommand( "mimosa-what");
        });

        after(function() {
          process.chdir.restore();
          cp.exec.restore();
        })

        it("switch into appropriate directory for install (mimosa's root)", function() {
          expect(chdirStub.calledWith(process.cwd())).to.be.true;
        });

        it("will attempt to install correct library/version if specific version provided", function() {
          expect(name).to.eql("npm install \"mimosa-what\" --save")
        });
      })

      describe("if package already exists", function(){
        var writeFileStub
          , cpdirStub
          , rmdirStub
          , library = "copy"
          ;

        before(function() {
          sinon.stub(fs, "existsSync", function(){ return true; });
          writeFileStub = sinon.stub(fs, "writeFileSync", function(){});
          cpdirStub = sinon.stub(wrench, "copyDirSyncRecursive", function() {});
          rmdirStub = sinon.stub(wrench, "rmdirSyncRecursive", function() {});
          sinon.stub(process, "chdir", function() {});
        });

        after(function() {
          wrench.copyDirSyncRecursive.restore();
          wrench.rmdirSyncRecursive.restore();
          fs.writeFileSync.restore();
          fs.existsSync.restore();
          process.chdir.restore();
        });

        describe("basics", function() {
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

          it("will remove the depedency from the package.json before installing", function() {
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
            rmdirStub.reset()
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
        });

        describe("if install is successful", function(){

          before(function(done) {
            rmdirStub.reset()
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

        });

      });

      describe("will attempt install", function() {

        it("using the right install string")

        describe("if error occurs during install", function(){
          it("will return to the original directory");
        });

        describe("if install is successful", function(){
          it("will return to the original directory");
        });
      });
    });
  });

  describe("if name is not provided", function() {
    it("will attempt a local npm install");
    describe("if local install fails", function() {
      it("will log error and go no further")
    });
    describe("if local install succeeds", function() {
      it("will switch into mimosa directory")
      it("will attempt npm install of local module into mimosa");
      describe("if local npm install succeeds", function() {
        it("will log success");
        it("will return to original directory")
      });
      describe("if local npm install fails", function() {
        it("will log success");
        it("will return to original directory");
      });
    });
  });


  utils.test.command.flags.help( command );
  utils.test.command.flags.debugSetup( "modinstall", command, "foo" );

});