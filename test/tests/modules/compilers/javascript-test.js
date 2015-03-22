var path = require( "path" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
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
  var output = "console.log('foooooooooooooo')\n" +
    "//# sourceMappingURL=data:application/json;base64,TESTTESTTESTeyJ2ZXJzaW9uIjozLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJmb29vb28uYmFyIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLE9BQUEsQ0FDRTtBQUFBLEVBQUEsT0FBQSxFQUFVLElBQUEsR0FBRyxDQUFDLENBQUssSUFBQSxJQUFBLENBQUEsQ0FBTCxDQUFZLENBQUMsT0FBYixDQUFBLENBQUQsQ0FBYjtBQUFBLEVBQ0EsS0FBQSxFQUNFO0FBQUEsSUFBQSxNQUFBLEVBQVMsc0JBQVQ7R0FGRjtDQURGLEVBSUksQ0FBRSxrQkFBRixDQUpKLEVBS0ksU0FBQyxXQUFELEdBQUE7QUFDQSxNQUFBLElBQUE7QUFBQSxFQUFBLEdBQUcsQ0FBQyxHQUFKLEdBQVUsR0FBVixDQUFBO0FBQUEsRUFDQSxJQUFBLEdBQVcsSUFBQSxXQUFBLENBQUEsQ0FEWCxDQUFBO1NBRUEsSUFBSSxDQUFDLE1BQUwsQ0FBYSxNQUFiLEVBSEE7QUFBQSxDQUxKLENBQUEsQ0FBQSIsInNvdXJjZXNDb250ZW50IjpbImNvbnNvbGUubG9nKCdmb28nKSJdfQ=="
  cb( null, output, sampleMapData)
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
    var compiler
      , determineOutputFile
      , compile
      , options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}]};

      ;

    before( function(done) {
      compiler = genCompiler( compileSuccessNoMap );
      getCallbacks( compiler, function( cbs ) {
        determineOutputFile = cbs.determineOutputFile;
        compile = cbs.compile;
        done();
      });
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
      determineOutputFile( fakeMimosaConfig, options, function() {
        expect(options.files[0].outputFileName).to.eql("fooooo.js")
        done();
      });
    });

    it("to compile file extensions provided by compiler", function( done ) {
      compile( fakeMimosaConfig, options, function() {
        expect(options.files[0].outputFileText).to.eql("console.log('fooooooo')")
        done();
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
            expect(compilerSpy.args[0][1]).to.eql(file)
            expect(typeof compilerSpy.args[0][2]).to.eql("function");
          });
        });
      });

      describe("if compile error occurs", function() {
        var compiler
          , options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:false}
          , compile
          ;

        before( function(done) {
          compiler = genCompiler( compileError );
          getCallbacks( compiler, function( cbs ) {
            compile = cbs.compile;
            done()
          });
        });

        it("will log error and break build if necessary", function(done){
          var errorSpy = sinon.spy(logger, "error")
          compile( fakeMimosaConfig, options, function() {
            expect(errorSpy.calledOnce).to.be.true;
            expect(errorSpy.args[0][0]).to.eql("File [[ fooooo.bar ]] failed compile. Reason: ERRORERRORERROR");
            expect(errorSpy.args[0][1]).to.eql({exitIfBuild:true})
            done();
          });
        });

        it("will continue workflow by calling next", function(done) {
          compile( fakeMimosaConfig, options, function() {
            expect(true).to.be.true;
            // failure will be timeout
            done();
          });
        });

        it("will not create file's output text", function(done){
          compile( fakeMimosaConfig, options, function() {
            expect(options.files[0].outputFileText).to.be.undefined;
            done();
          });
        });
      });
    });

    describe("if compile successful", function() {
      var compiler
        , options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:false}
        , compile
        ;

      before( function(done) {
        compiler = genCompiler( compileSuccessNoMap );
        getCallbacks( compiler, function( cbs ) {
          compile = cbs.compile;
          done()
        });
      });

      it("will create source maps if source map is included", function(done) {
        var compiler2 = genCompiler( compileSuccessMapObject );
        getCallbacks( compiler2, function( cbs ) {
          cbs.compile( fakeMimosaConfig, options, function() {
            expect(options.files[0].outputFileText.split("\n")[1].substring(0,20)).to.eql("//# sourceMappingURL");
            done();
          });
        });
      });

      it("will create file's output text without source maps", function(done) {
        compile( fakeMimosaConfig, options, function() {
          expect(options.files[0].outputFileText).to.eql("console.log(\'fooooooo\')");
          done();
        });
      });

      it("will continue workflow by calling next", function(done) {
        compile( fakeMimosaConfig, options, function() {
          // failing test would be timeout
          expect(true).to.be.true;
          done();
        });
      });
    });
  });

  describe("source map creation", function() {

    it("will make no changes if source map already present", function(done) {
      var options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:false};
      var compiler  = genCompiler( compileSuccessMapEmbedded );
      getCallbacks( compiler, function( cbs ) {
        cbs.compile( fakeMimosaConfig, options, function() {
          var text = options.files[0].outputFileText;
          expect(text.indexOf("TESTTESTTEST")).to.eql(81)
          expect(text.match(/sourceMappingURL/).length).to.eql(1)
          done()
        });
      });
    });

    var goodSourceMap = function(type, comp) {
      it("can handle a " + type + " source map", function(done) {
        var options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:false};
        var compiler  = genCompiler( comp );
        getCallbacks( compiler, function( cbs ) {
          cbs.compile( fakeMimosaConfig, options, function() {
            var text = options.files[0].outputFileText;
            expect(text.match(/sourceMappingURL/).length).to.eql(1)
            done();
          });
        });
      });
    };

    goodSourceMap("object", compileSuccessMapObject);
    goodSourceMap("string", compileSuccessMapString);

    it("will create the correct source map", function(done) {
      var options = {files:[{inputFileName:"fooooo.bar", inputFileText:"console.log('foo')"}], isVendor:false};
      var compiler  = genCompiler( compileSuccessMapObject );
      getCallbacks( compiler, function( cbs ) {
        cbs.compile( fakeMimosaConfig, options, function() {
          var text = options.files[0].outputFileText.split("\n")[1];
          expect(text).to.eql("//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJmb29vb28uYmFyIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLE9BQUEsQ0FDRTtBQUFBLEVBQUEsT0FBQSxFQUFVLElBQUEsR0FBRyxDQUFDLENBQUssSUFBQSxJQUFBLENBQUEsQ0FBTCxDQUFZLENBQUMsT0FBYixDQUFBLENBQUQsQ0FBYjtBQUFBLEVBQ0EsS0FBQSxFQUNFO0FBQUEsSUFBQSxNQUFBLEVBQVMsc0JBQVQ7R0FGRjtDQURGLEVBSUksQ0FBRSxrQkFBRixDQUpKLEVBS0ksU0FBQyxXQUFELEdBQUE7QUFDQSxNQUFBLElBQUE7QUFBQSxFQUFBLEdBQUcsQ0FBQyxHQUFKLEdBQVUsR0FBVixDQUFBO0FBQUEsRUFDQSxJQUFBLEdBQVcsSUFBQSxXQUFBLENBQUEsQ0FEWCxDQUFBO1NBRUEsSUFBSSxDQUFDLE1BQUwsQ0FBYSxNQUFiLEVBSEE7QUFBQSxDQUxKLENBQUEsQ0FBQSIsInNvdXJjZXNDb250ZW50IjpbImNvbnNvbGUubG9nKCdmb28nKSJdfQ==")
          done()
        });
      });
    });
  });

  describe("output file determination", function() {
    it("will do nothing if no output files");
    it("will set the destinationFile function");
    it("will create output file names for all input files");
  });
});