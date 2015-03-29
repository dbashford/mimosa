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
    compilerType: "copy",
    determineOutputFile: function( config, options ) {
      return "thisisamiscfile.js";
    }
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
      , options = {files:[{inputFileName:"fooooo.js", inputFileText:"console.log('foo')"}]};
      ;

    before( function(done) {
      compiler = genCompiler(fakeCopyCompilerImpl());
      compilerUtils.getCallbacks( compiler, fakeMimosaConfig, function( cbs ) {
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
        expect(options.files[0].outputFileText).to.eql("console.log('foo')")
        done();
      });
    });
  });

});