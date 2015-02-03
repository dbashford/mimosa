var fs = require( "fs" )
  , path = require( "path" )
  , sinon = require( "sinon" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , deleteModule = require( path.join(process.cwd(), "lib", "modules", "file", "delete") )
  , fakeMimosaConfig = utils.fakeMimosaConfig();
  ;

describe( "Mimosa file deleting workflow module", function(){
  var deleteFunction;

  before(function(done) {
    utils.testRegistration( deleteModule, function( func ) {
      deleteFunction = func;
      done();
    });
  });

  describe( "will invoke the lifecycle callback", function(){

    var spy;

    before(function() {
      spy = sinon.spy();
    });

    afterEach(function() {
      spy.reset();
    });

    it("when no destination file can be determined", function(){
      deleteFunction( fakeMimosaConfig, { destinationFile: null }, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it("when the file to delete does not exist", function() {
      var existsStub = sinon.stub( fs, "exists", function(fileName, cb){
        cb(false);
        expect( existsStub.calledOnce ).to.be.true;
        expect( spy.calledOnce ).to.be.true;
        fs.exists.restore();
      });
      deleteFunction( fakeMimosaConfig, { destinationFile: function(){ return "a"; } }, spy );
    });

    it("after failing to delete the file", function() {
      var logSpy = sinon.spy(fakeMimosaConfig.log, "error");
      var unlinkStub = sinon.stub( fs, "unlink", function(fileName, cb) {
        cb("ERROR");
        expect( spy.calledOnce ).to.be.true;
        expect( logSpy.calledOnce ).to.be.true;
        fs.unlink.restore();
        fs.exists.restore();
        logSpy.reset();
      });
      var existsStub = sinon.stub( fs, "exists", function(fileName, cb){
        cb(true);
      });
      deleteFunction( fakeMimosaConfig, { destinationFile: function(){ return "a"; } }, spy );
    });

    it("after deleting the file", function() {
      var logSpy = sinon.spy(fakeMimosaConfig.log, "success");
      var unlinkStub = sinon.stub( fs, "unlink", function(fileName, cb) {
        cb();
        expect( spy.calledOnce ).to.be.true;
        expect( logSpy.calledOnce ).to.be.true;
        fs.unlink.restore();
        fs.exists.restore();
        logSpy.reset();
      });
      var existsStub = sinon.stub( fs, "exists", function(fileName, cb){
        cb(true);
      });
      deleteFunction( fakeMimosaConfig, { destinationFile: function(){ return "a"; } }, spy );
    });
  });

});
