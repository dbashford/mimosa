var path = require( "path" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , MiscCompiler = require( path.join(process.cwd(), "lib", "modules", "compilers", "misc") )
  , compilerUtils = require( "./utils" )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

var fakeCopyCompilerImpl = function() {
  return {
    name: "testCopyCompiler",
    extensions: function(config) {
      return ["js", "png"];
    },
    compile: function( config, options, cb ) {
      var file = options.files[0];
      if (file) {
        file.outputFileText = file.inputFileText;
      }
      cb();
    },
    compilerType: "copy"
  }
};

var fakeMiscCompilerImpl = function() {
  return {
    name: "testMiscCompiler",
    extensions: function(config) {
      return ["js", "png"];
    },
    compile: function( config, options, cb ) {
      cb();
    },
    compilerType: "misc"
  }
};

var genCompiler = function(comp) {
  return new MiscCompiler( fakeMimosaConfig, comp );
}

describe("Mimosa's Misc compiler wrapper", function() {
  describe("will register", function() {
    var compiler
      , determineOutputFile
      , compile
      , compilerImpl
      , options = {files:[{inputFileName:"fooooo.js", inputFileText:"console.log('foo')"}]};
      ;

    before( function(done) {
      compilerImpl = fakeCopyCompilerImpl()
      compiler = genCompiler(compilerImpl);
      compilerUtils.getCallbacks( compiler, fakeMimosaConfig, function( cbs ) {
        determineOutputFile = cbs.determineOutputFile;
        compile = cbs.compile;
        done();
      });
    });

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
        expect(options.files[0].outputFileText).to.eql("console.log('foo')")
        done();
      });
    });

    it("using proper extensions", function() {
      expect(compiler.extensions).to.eql(compilerImpl.extensions())
    })
  });

  describe("proxies directly to child compilers compile function", function() {
    var compilerImpl
      , compile
      ;

    before( function(done) {
      compilerImpl = fakeCopyCompilerImpl();
      var compiler = genCompiler(compilerImpl);
      compilerUtils.getCallbacks( compiler, fakeMimosaConfig, function( cbs ) {
        compile = cbs.compile;
        done();
      });
    });

    it("for all compilers", function() {
      expect(compilerImpl.compile).to.eql(compile);
    });
  });

  describe("output file determination", function() {

    describe("for copy compilers", function() {
      var determineOutputFile;

      before( function(done) {
        var compiler = genCompiler(fakeCopyCompilerImpl());
        compilerUtils.getCallbacks( compiler, fakeMimosaConfig, function( cbs ) {
          determineOutputFile = cbs.determineOutputFile;
          done();
        });
      });

      it("will do nothing if no output files", function(done) {
        var options = {files:[]};
        determineOutputFile(fakeMimosaConfig, options, function() {
          expect(options.destinationFile).to.be.undefined;
          done();
        });
      });

      it("will set destination file when there are files", function(done) {
        var options = {files:[{inputFileName:"fooooo.js", inputFileText:"console.log('foo')"}]};
        determineOutputFile(fakeMimosaConfig, options, function() {
          expect(options.destinationFile).to.be.function;
          expect(options.destinationFile("fooooo.js")).to.eql("fooooo.js")
          done();
        });
      });

      it("will output file name", function(done) {
        var options = {files:[{inputFileName:"fooooo.js", inputFileText:"console.log('foo')"}]};
        determineOutputFile(fakeMimosaConfig, options, function() {
          expect(options.files[0].outputFileName).to.eql("fooooo.js");
          done();
        });
      });
    });


    describe("for misc compilers", function() {
      var determineOutputFile
        , compilerImpl
        ;

      before( function(done) {
        compilerImpl = fakeMiscCompilerImpl();
        compilerImpl.determineOutputFile = sinon.spy();
        compiler = genCompiler(compilerImpl);
        compilerUtils.getCallbacks( compiler, fakeMimosaConfig, function( cbs ) {
          determineOutputFile = cbs.determineOutputFile;
          done();
        });
      });

      afterEach(function() {
        compilerImpl.determineOutputFile.reset();
      })

      it("will do nothing if no output files", function(done) {
        var options = {files:[]};
        determineOutputFile(fakeMimosaConfig, options, function() {
          expect(compilerImpl.determineOutputFile.callCount).to.eql(0);
          done();
        });
      });

      it("will call determineOutputFile if it exists on compiler", function(done) {
        var options = {files:[{inputFileName:"fooooo.js", inputFileText:"console.log('foo')"}]};
        determineOutputFile(fakeMimosaConfig, options, function() {
          expect(compilerImpl.determineOutputFile.callCount).to.eql(1);
          done();
        });
      });

    });

  });
});