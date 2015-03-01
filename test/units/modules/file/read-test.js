var fs = require( "fs" )
  , path = require( "path" )
  , sinon = require( "sinon" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , readModule = require( path.join(process.cwd(), "lib", "modules", "file", "read") )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

describe( "Mimosa file reading workflow module", function(){
  var readFunction;

  before(function(done) {
    utils.test.registration( readModule, function( func ) {
      readFunction = func;
      done();
    });
  });

  describe( "when invoked with no files", function() {

    var spy;

    before(function() {
      spy = sinon.spy();
    });

    afterEach(function() {
      spy.reset();
    });

    it( "will invoke the lifecycle callback when no files array", function(){
      readFunction( fakeMimosaConfig, { files: null }, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it( "will invoke the lifecycle callback when empty files array", function(){
      readFunction( fakeMimosaConfig, { files: [] }, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it( "will not attempt to read any files", function() {
      var readFileSpy = sinon.spy( fs, "readFile" );
      readFunction( fakeMimosaConfig, { files: [] }, function(){} );
      expect( readFileSpy.called ).to.be.false;
      fs.readFile.restore();
    });

  });

  describe( "when invoked with files having no input name", function() {

    it( "will not attempt to read any files", function() {
      var readFileSpy = sinon.spy( fs, "readFile" );
      var options = {files:[utils.fake.file()]};
      options.files[0].inputFileName = null;
      readFunction( fakeMimosaConfig, options, function(){} );
      expect( readFileSpy.called ).to.be.false;
      fs.readFile.restore();
    });

  });

  describe("when invoked with an valid file", function() {

    describe("that errors out on read", function() {

      it("will write error and call lifecycle callback", function(done){
        var lifecycleSpy = sinon.spy();
        var logSpy = sinon.spy( fakeMimosaConfig.log, "error" );

        var options = {
          files: [utils.fake.file()]
        };

        var readFileStub = sinon.stub( fs, "readFile", function(name, cb){
          cb("ErrorErrorError", null);

          expect(name).to.eql(options.files[0].inputFileName);
          expect( lifecycleSpy.called ).to.be.true;

          var logCalled = logSpy.calledWith(
            "Failed to read file [[ " +
            options.files[0].inputFileName +
            " ]], ErrorErrorError" );
          expect(logCalled).to.be.true;

          fs.readFile.restore();
          lifecycleSpy.reset();
          fakeMimosaConfig.log.error.restore();

          done();
        });

        readFunction( fakeMimosaConfig, options, lifecycleSpy );
      });
    });
  });

  describe("when invoked with an valid file", function() {

    describe("that errors out", function() {

      it("will write error and call lifecycle callback", function(done){
        var lifecycleSpy = sinon.spy();
        var logSpy = sinon.spy( fakeMimosaConfig.log, "error" );

        var options = {
          files: [utils.fake.file()]
        };

        var readFileStub = sinon.stub( fs, "readFile", function(name, cb){
          cb("ErrorErrorError", null);

          expect(name).to.eql(options.files[0].inputFileName);
          expect( lifecycleSpy.called ).to.be.true;

          var logCalled = logSpy.calledWith(
            "Failed to read file [[ " +
            options.files[0].inputFileName +
            " ]], ErrorErrorError" );
          expect(logCalled).to.be.true;

          fs.readFile.restore();
          lifecycleSpy.reset();
          fakeMimosaConfig.log.error.restore();

          done();
        });

        readFunction( fakeMimosaConfig, options, lifecycleSpy );
      });
    });

    var testReadText = function( withBuffer ) {
      it("will return a buffer for non javascript/template/css files", function(done) {
        var lifecycleSpy = sinon.spy();
        var options = {
          files: [utils.fake.file()]
        };

        if ( !withBuffer ) {
          options.isJavascript = true;
        }

        var readFileStub = sinon.stub( fs, "readFile", function(name, cb){
          cb(null, new Buffer("F"));

          expect(name).to.eql(options.files[0].inputFileName);
          expect( lifecycleSpy.called ).to.be.true;

          if ( withBuffer ) {
            expect(typeof(options.files[0].inputFileText)).to.eql("object");
            expect(options.files[0].inputFileText.toString()).to.eql("F");
          } else {
            expect(typeof(options.files[0].inputFileText)).to.eql("string");
            expect(options.files[0].inputFileText).to.eql("F");
          }

          fs.readFile.restore();
          lifecycleSpy.reset();

          done();
        });

        readFunction( fakeMimosaConfig, options, lifecycleSpy );
      });
    };

    testReadText(true);
    testReadText(false);
  });
});
