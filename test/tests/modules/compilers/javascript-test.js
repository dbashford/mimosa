var path = require( "path" )
  , sinon = require( "sinon" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , JavaScriptCompiler = require( path.join(process.cwd(), "lib", "modules", "compilers", "javascript") )
  , fileUtils = require( path.join(process.cwd(), "lib", "util", "file" ) )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

var sampleMapData = {
  "version": 3,
  "file": "",
  "sourceRoot": "",
  "sources": [
    "main.coffee.src"
  ],
  "names": [],
  "mappings": "AAAA,OAAA,CACE;AAAA,EAAA,OAAA,EAAU,IAAA,GAAG,CAAC,CAAK,IAAA,IAAA,CAAA,CAAL,CAAY,CAAC,OAAb,CAAA,CAAD,CAAb;AAAA,EACA,KAAA,EACE;AAAA,IAAA,MAAA,EAAS,sBAAT;GAFF;CADF,EAII,CAAE,kBAAF,CAJJ,EAKI,SAAC,WAAD,GAAA;AACA,MAAA,IAAA;AAAA,EAAA,GAAG,CAAC,GAAJ,GAAU,GAAV,CAAA;AAAA,EACA,IAAA,GAAW,IAAA,WAAA,CAAA,CADX,CAAA;SAEA,IAAI,CAAC,MAAL,CAAa,MAAb,EAHA;AAAA,CALJ,CAAA,CAAA"
};

var sampleMapDataString = JSON.stringify(sampleMapData);

var compileError = function( config, file, cb) {
  cb( "ERRORERRORERROR", null)
};
var compileSuccessNoMap = function( config, file, cb ) {
  cb( null, "console.log('fooooooo')");
};
var compileSuccessMapString = function( config, file, cb ) {
  cb( null, "console.log('fooooooooo')", sampleMapDataString)
};
var compileSuccessMapObject = function( config, file, cb ) {
  cb( null, "console.log('foooooooooooo')", sampleMapData)
};
var compileSuccessMapEmbedded = function( config, file, cb ) {
  cb( null, "console.log('foooooooooooooo')", sampleMapData)
};
var compileSuccessDeprecated = function( config, file, cb ) {
  cb( null, "console.log('fooooooooooooooooo')", null, sampleMapData)
}

var fakeJavascriptCompilerImpl = function() {
  return {
    name: "testJavaScriptCompiler",
    extensions: function(config) {
      return ["js", "coffee"];
    }
  }
};

var genCompiler = function(compileFunct) {
  var compImpl = fakeJavascriptCompilerImpl()
  compImpl.compile = compileFunct;
  var compiler = new JavaScriptCompiler( fakeMimosaConfig, compImpl );
  return compiler;
}

var getCallbacks = function( compiler, cb ) {
  var i = 0
    , determineOutputFile
    , compile
    ;

  compiler.registration( fakeMimosaConfig, function(a, b, lifecycle, d) {
    if (i++) {
      cb({
        determineOutputFile: determineOutputFile,
        compile: lifecycle
      });
    } else {
      determineOutputFile = lifecycle;
    }
  })
};

describe("Mimosa's JavaScript compiler wrapper", function() {

  describe("will register", function() {
    var compiler;

    before( function() {
      compiler = genCompiler( compileSuccessNoMap );
    })

    it("with valid parameters in register function", function( done ) {
      var i = 0;
      utils.test.registration( compiler, function() {
        if (i++) {
          done();
        }
      });
    });

    it("to determine the output file for javascript files", function( done ) {
      var options = {files:[{inputFileName:"fooooo.bar"}]};
      getCallbacks( compiler, function( cbs ) {
        cbs.determineOutputFile( fakeMimosaConfig, options, function() {
          expect(options.files[0].outputFileName).to.eql("fooooo.js")
          done();
        });
      });
    });

    it("to compile file extensions provided by compiler", function( done ) {
      var options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}]};
      getCallbacks( compiler, function( cbs ) {
        cbs.compile( fakeMimosaConfig, options, function() {
          expect(options.files[0].outputFileText).to.eql("console.log('fooooooo')")
          done();
        });
      });
    });
  });

  describe("compiling", function() {

    // will time out if fail
    it("will not attempt to compile anything if no files to compile", function( done ) {
      var compiler  = genCompiler( compileSuccessNoMap );
      var options = {files:[]};
      getCallbacks( compiler, function( cbs ) {
        cbs.compile( fakeMimosaConfig, options, function() {
          // calling the callback is a successful test
          expect(true).to.be.true;
          done();
        });
      });
    });

    describe("for each file to compile", function() {
      var compiler;

      before( function() {
        compiler = genCompiler( compileSuccessNoMap );
      })

      var testVendor = function(isVendor, done) {
        var options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:isVendor};
        var compiler  = genCompiler( compileSuccessNoMap );
        var compilerSpy = sinon.spy(compiler, "_compile");
        getCallbacks( compiler, function( cbs ) {
          cbs.compile( fakeMimosaConfig, options, function() {
            expect(compilerSpy.args[0][1].isVendor).to.eql(isVendor);
            compiler._compile.restore();
            done();
          });
        });
      };

      it("will not flag file as vendor if indicated to be vendor", function(done) {
        testVendor(false, done)
      });

      it("will flag file as vendor if indicated to be vendor", function(done) {
        testVendor(true, done)
      });

      it("will call the compilers compile function with appropriate arguments", function() {
        var options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:false};
        var compiler  = genCompiler( compileSuccessNoMap );
        var compilerSpy = sinon.spy(compiler.compiler, "compile");

        getCallbacks( compiler, function( cbs ) {
          cbs.compile( fakeMimosaConfig, options, function() {
            expect(compilerSpy.args[0][0]).to.eql(fakeMimosaConfig);
            var file = options.files[0];
            file.isVendor = false;
            expect(compilerSpy.args[0][1]).to.eql(file);
          });
        });
      });

      describe("if compile error occurs", function() {
        it("will log error");
        it("will break build if it needs breaking");
        it("will continue workflow by calling next");
        it("will not create file's output text");
      });
    });

    describe("if compile successful", function() {
      it("will create source maps if source map is included");
      it("will not create source maps if source maps are not included");
      it("will create file's output text");
      it("will continue workflow by calling next");
    });
  });

  describe("source map creation", function() {
    it("will make no changes if source map already present");
    it("can handle an object source map");
    it("can handle a string source map");
    it("will create the correct source map");
  });

  describe("output file determination", function() {
    it("will do nothing if no output files");
    it("will set the destinationFile function");
    it("will create output file names for all input files");
  });

});