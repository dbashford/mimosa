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

  describe("when run on local module", function() {
    describe("will error out", function() {
      it("when no local package.json")
      it("when package.json has no name")
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