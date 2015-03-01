var fs = require( "fs" )
  , path = require( "path" )
  , sinon = require( "sinon" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , writeModule = require( path.join(process.cwd(), "lib", "modules", "file", "write") )
  , fileUtils = require( path.join(process.cwd(), "lib", "util", "file" ) )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

describe( "Mimosa file writing workflow module", function(){

  var writeFunction;

  before(function(done) {
    utils.test.registration( writeModule, function( func ) {
      writeFunction = func;
      done();
    });
  })

  describe( "when invoked with no files", function() {

    var spy;

    before(function() {
      spy = sinon.spy();
    });

    afterEach(function() {
      spy.reset();
    });

    it( "will invoke the lifecycle callback when no files array", function(){
      writeFunction( fakeMimosaConfig, { files: null }, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it( "will invoke the lifecycle callback when empty files array", function(){
      writeFunction( fakeMimosaConfig, { files: [] }, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it( "will not attempt to write any files", function() {
      var writeFileSpy = sinon.spy( fileUtils, "writeFile" );
      writeFunction( fakeMimosaConfig, { files: [] }, function(){} );
      expect( writeFileSpy.called ).to.be.false;
      fileUtils.writeFile.restore();
    });

  });

  describe( "when invoked with one file", function() {
    var callbackSpy;

    before(function() {
      callbackSpy = sinon.spy();
    });

    afterEach(function() {
      callbackSpy.reset();
    });

    it( "with blank output will warn the user, write the file and execute the lifecycle callback", function() {
      var warnStub = sinon.stub( fakeMimosaConfig.log, "warn" );
      var writeFileStub = sinon.stub( fileUtils, "writeFile" );
      var options = { files: [utils.fake.file()] };
      options.files[0].outputFileText = "";
      writeFunction( fakeMimosaConfig, options, callbackSpy );
      expect( warnStub.calledOnce ).to.be.true;
      var calledWithCorrect = warnStub.calledWith( "File [[ " + options.files[0].inputFileName + " ]] is empty." );
      expect( calledWithCorrect ).to.be.true;
      fileUtils.writeFile.restore();
      fakeMimosaConfig.log.warn.restore();
    });

    it( "lacking an output name will not write file and will call lifecycle callback", function() {
      var writeFileSpy = sinon.spy( fileUtils, "writeFile" );
      var options = { files: [utils.fake.file()] };
      options.files[0].outputFileName = null;
      writeFunction( fakeMimosaConfig, options, callbackSpy );
      expect( callbackSpy.calledOnce ).to.be.true;
      expect( writeFileSpy.called ).to.be.false;
      fileUtils.writeFile.restore();
    });

    it( "will attempt to write one file, log success, and lifecycle callback", function(){
      var successStub = sinon.stub( fakeMimosaConfig.log, "success" );
      var options = { files: [utils.fake.file()] };
      var writeFileStub = sinon.stub(
        fileUtils,
        "writeFile",
        function( outputFileName, outputFileText, writeCallback ) {
          expect( outputFileName ).to.equal( options.files[0].outputFileName );
          expect( outputFileText ).to.equal( options.files[0].outputFileText );
          writeCallback(null, outputFileName);
        }
      );

      writeFunction( fakeMimosaConfig, options, callbackSpy );

      // will attempt to write file once
      expect( writeFileStub.calledOnce ).to.be.true;

      // will call lifecycle callback once
      expect( callbackSpy.calledOnce ).to.be.true;
      // will log success for write of file
      expect( successStub.calledOnce ).to.be.true;
      var calledWithCorrect = successStub.calledWith( "Wrote file [[ " + options.files[0].outputFileName + " ]]" );
      expect( calledWithCorrect ).to.be.true;

      fileUtils.writeFile.restore();
      fakeMimosaConfig.log.success.restore();
    });

    it( "and an error occurs during write, will log error and call lifecycle callback", function(){
      var errorText = "blah blah blah";
      var errorStub = sinon.stub( fakeMimosaConfig.log, "error" );
      var options = { files: [utils.fake.file()] };
      var writeFileStub = sinon.stub(
        fileUtils,
        "writeFile",
        function( outputFileName, outputFileText, writeCallback ) {
          expect( outputFileName ).to.equal( options.files[0].outputFileName );
          expect( outputFileText ).to.equal( options.files[0].outputFileText );
          writeCallback(errorText, outputFileName);
        }
      );

      writeFunction( fakeMimosaConfig, options, callbackSpy );

      // will attempt to write file once
      expect( writeFileStub.calledOnce ).to.be.true;

      // will call lifecycle callback once
      expect( callbackSpy.calledOnce ).to.be.true;

      // will log error with message for failed write of file
      expect( errorStub.calledOnce ).to.be.true;
      var calledWithCorrect = errorStub.calledWith( "Failed to write new file [[ " + options.files[0].outputFileName + " ]], Error: " + errorText );
      expect( calledWithCorrect ).to.be.true;

      fileUtils.writeFile.restore();
      fakeMimosaConfig.log.error.restore();
    });
  });

  describe( "when invoked with two files", function() {
    var callbackSpy;

    before(function() {
      callbackSpy = sinon.spy();
    });

    afterEach(function() {
      callbackSpy.reset();
    });

    it( "will attempt to write one file, log success, and lifecycle callback", function(){
      var successStub = sinon.stub( fakeMimosaConfig.log, "success" );
      var options = { files: [utils.fake.file(), utils.fake.file()] };
      var i = 0;
      var writeFileStub = sinon.stub(
        fileUtils,
        "writeFile",
        function( outputFileName, outputFileText, writeCallback ) {
          expect( outputFileName ).to.equal( options.files[i].outputFileName );
          expect( outputFileText ).to.equal( options.files[i++].outputFileText );
          writeCallback(null, outputFileName);
        }
      );

      writeFunction( fakeMimosaConfig, options, callbackSpy );

      // will attempt to write file once
      expect( writeFileStub.calledTwice ).to.be.true;

      // will call lifecycle callback once
      expect( callbackSpy.calledOnce ).to.be.true;

      // will log success for write of file
      expect( successStub.calledTwice ).to.be.true;
      var successCall1 = successStub.getCall(0);
      var successCall2 = successStub.getCall(1);

      var calledWithCorrect = successCall1.calledWith( "Wrote file [[ " + options.files[0].outputFileName + " ]]" );
      expect( calledWithCorrect ).to.be.true;

      calledWithCorrect = successCall2.calledWith( "Wrote file [[ " + options.files[1].outputFileName + " ]]" );
      expect( calledWithCorrect ).to.be.true;

      fileUtils.writeFile.restore();
      fakeMimosaConfig.log.success.restore();
    });

    it( "and an error occurs during write, will log error and call lifecycle callback", function(){
      var errorText = "blah blah blah";
      var errorStub = sinon.stub( fakeMimosaConfig.log, "error" );
      var options = { files: [utils.fake.file(), utils.fake.file()] };
      var i = 0;
      var writeFileStub = sinon.stub(
        fileUtils,
        "writeFile",
        function( outputFileName, outputFileText, writeCallback ) {
          expect( outputFileName ).to.equal( options.files[i].outputFileName );
          expect( outputFileText ).to.equal( options.files[i].outputFileText );
          if (i++ === 1) {
            writeCallback( errorText, outputFileName );
          } else {
            writeCallback( null, outputFileName);
          }
        }
      );

      writeFunction( fakeMimosaConfig, options, callbackSpy );

      // will attempt to write file once
      expect( writeFileStub.calledTwice ).to.be.true;

      // will call lifecycle callback once
      expect( callbackSpy.calledOnce ).to.be.true;

      // will log error with message for failed write of file
      expect( errorStub.calledOnce ).to.be.true;
      var calledWithCorrect = errorStub.calledWith( "Failed to write new file [[ " + options.files[1].outputFileName + " ]], Error: " + errorText );
      expect( calledWithCorrect ).to.be.true;

      fileUtils.writeFile.restore();
      fakeMimosaConfig.log.error.restore();
    });
  });
});