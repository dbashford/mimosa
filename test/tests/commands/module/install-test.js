var cp = require( 'child_process' )
  , path = require( "path" )
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
        })

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
        it("will back up the package before installing");
        it("will remove the depedency from the package.json before installing")

        describe("will attempt install", function() {

          it("using the right install string")

          describe("if error occurs during install", function(){
            it("will place backup back");
            it("will update package.json back to where it was");
            it("will remove package backup");
            it("will return to the original directory");
          });

          describe("if install is successful", function(){
            it("will remove package backup");
            it("will return to the original directory");
          });

        })
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