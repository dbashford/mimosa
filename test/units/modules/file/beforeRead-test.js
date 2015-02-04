var path = require( "path" )
  , sinon = require( "sinon" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , beforeReadModule = require( path.join(process.cwd(), "lib", "modules", "file", "beforeRead") )
  , fileUtils = require( path.join(process.cwd(), "lib", "util", "file" ) )
  , fakeMimosaConfig = utils.fakeMimosaConfig();
  ;

describe( "Mimosa beforeRead workflow module", function(){
  var startupFunction
    , postStartupFunction
    , spy
    ;

  before(function(done) {
    var i = 0;
    utils.testRegistration( beforeReadModule, function( func ) {
      if (i++) {
        postStartupFunction = func;
        done();
      } else {
        startupFunction = func;
      }
    });

    spy = sinon.spy();

  });

  afterEach(function() {
    spy.reset();
  });

  describe( "when invoked during startup", function() {

    it( "will invoke the lifecycle callback immediately when forced", function(){
      var postStartupFuncSpy = sinon.spy(postStartupFunction);
      fakeMimosaConfig.__forceJavaScriptRecompile = true;
      var opts = {
        isJSNotVendor:true,
        files:[]
      };
      startupFunction( fakeMimosaConfig, opts, spy );
      expect( spy.calledOnce ).to.be.true;
      expect( postStartupFuncSpy.callCount ).to.eql(0);
      postStartupFuncSpy.reset();
      delete fakeMimosaConfig.__forceJavaScriptRecompile;
    });

    it( "will not invoke the lifecycle callback immediately if forced and vendor file", function(){
      fakeMimosaConfig.__forceJavaScriptRecompile = true;
      var opts = {
        isJSNotVendor:false,
        files:["foo"]
      };
      var forEachSpy = sinon.spy(opts.files, "forEach", function(){});
      startupFunction( fakeMimosaConfig, opts, spy );
      expect( spy.calledOnce ).to.be.true;
      expect( forEachSpy.calledOnce ).to.be.true;
      forEachSpy.reset();
      delete fakeMimosaConfig.__forceJavaScriptRecompile;
    });

  });

  describe( "when invoked after startup", function() {

    it("with no files the lifecycle callback will be immediately executed", function(){
      postStartupFunction( fakeMimosaConfig, {files:[]}, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it("with many files with invalid extension will let file through untouched", function() {
      var options = {
        files:["foo.css", "bar.bar"]
      };
      postStartupFunction( fakeMimosaConfig, options, spy );
      expect( spy.calledOnce ).to.be.true;
      expect(options.files[0]).to.eql("foo.css");
      expect(options.files[1]).to.eql("bar.bar");
    });

    it("with many javascript files and recompile forced, will let files through untouched", function() {
      var options = {
        files:["foo.js", "bar.js"],
        isJavascript: true
      };
      fakeMimosaConfig.__forceJavaScriptRecompile = true;
      postStartupFunction( fakeMimosaConfig, options, spy );
      expect( spy.calledOnce ).to.be.true;
      expect(options.files[0]).to.eql("foo.js");
      expect(options.files[1]).to.eql("bar.js");
      delete fakeMimosaConfig.__forceJavaScriptRecompile;
    });


    it("with will remove files that do not need compilation", function() {
      var options = {
        files:[{
          inputFileName:"foo.js",
          outputFileName:"notnull"
        },{
          inputFileName:"bar.js",
          outputFileName:"notnull"
        },{
          inputFileName:"baz.js",
          outputFileName:"notnull"
        }]
      };

      sinon.stub(fileUtils, "isFirstFileNewer", function(inputName, outputName, cb){
        if (inputName === "foo.js") {
          cb(false);
        } else {
          cb(true);
        }
      });

      postStartupFunction( fakeMimosaConfig, options, spy );
      expect( spy.calledOnce ).to.be.true;
      expect(options.files.length).to.eql(2);
      expect(options.files[0].inputFileName).to.eql("bar.js");
      expect(options.files[1].inputFileName).to.eql("baz.js");
      fileUtils.isFirstFileNewer.restore();
    });
  });
});