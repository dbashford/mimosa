var path = require( "path" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , TemplateCompiler = require( path.join(process.cwd(), "lib", "modules", "compilers", "template") )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

var fakeTemplateCompilerImpl = function() {
  return {
    clientLibrary:"foo.js",
    name: "testTemplateCompiler",
    handlesNamespacing: false,
    extensions: function(config) {
      return ["hbs", "handlebars"];
    },
    compile: function( config, file, cb) {
      cb(err, "this is a result");
    },
    prefix: function( config, libPath ) {
      return "PREFIX " + libPath;
    },
    suffix: function( config ) {
      return "SUFFIX"
    }
  }
};

var genCompiler = function(mc, comp) {
  return new TemplateCompiler( mc, comp );
};

describe("Mimosa's template compiler", function() {

  describe("template name generation", function() {
    it("will create template names based on the name of the file");
    it("will create template names based on full file path");
    it("will create template names base on transform regex");
    it("will create template names based on transform function");
    it("will error out if name created isn't a string");
  });

  describe("will remove client library and execute callback", function() {
    describe("but will not remove library", function() {
      it("if no client path");
      it("if client path does not exist");
    });
    it("if client path exists")
  });

  it("will notify the user if templates have the same name");

  it("will incorporate a template preamble with useful template information");

  describe("will generate destination file names", function(){
    it("for each template output block");
    it("for a specific compiler name");
    it("when no specific compiler name provided");
  });

  describe("during initialization", function() {
    it("will claim a file if it is inside one of the folders from the config");
    it("will claim extension if being processed");
  });

  describe("when instantiated", function() {

    describe("will set up paths", function() {
      var compiler
        , mimosaConfig
        ;

      before(function() {
        var compilerImpl = fakeTemplateCompilerImpl();
        mimosaConfig = utils.fake.mimosaConfig();
        mimosaConfig.vendor.javascripts = path.join(__dirname, mimosaConfig.vendor.javascripts);
        mimosaConfig.watch.sourceDir = path.join(__dirname);
        mimosaConfig.watch.compiledDir = path.join("public");
      })

      it("with default config", function() {
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
      });

      it("with wrapType set to something else", function() {
        mimosaConfig.template.wrapType = "foo";
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
        mimosaConfig.template.wrapType = "amd"; // set back
      });

      it("with writeLibrary turned off", function() {
        mimosaConfig.template.writeLibrary = false; //set back
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
        mimosaConfig.template.writeLibrary = true; // set back
      });
    });

    describe("will not set up paths", function() {
      var compiler
        , mimosaConfig
        ;

      before(function() {
        var compilerImpl = fakeTemplateCompilerImpl();
        mimosaConfig = utils.fake.mimosaConfig();
        mimosaConfig.vendor.javascripts = path.join(__dirname, mimosaConfig.vendor.javascripts);
        mimosaConfig.watch.sourceDir = path.join(__dirname);
        mimosaConfig.watch.compiledDir = path.join("public");
      });

      it("if no client lirbary", function() {
        compilerImpl.clientLibrary = false;
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.be.undefined;
        expect(compiler.clientPath).to.be.undefined;
        compilerImpl.clientLibrary = true; // set back
      });

      it("if wrap type is not AMD and writeLibrary is turned off", function() {
        mimosaConfig.template.wrapType = "foo";
        mimosaConfig.template.writeLibrary = false;
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.be.undefined;
        expect(compiler.clientPath).to.be.undefined;
      });
    })
  });

  it("will register with valid parameters in register function", function(done) {
    var compilerImpl = fakeTemplateCompilerImpl()
    var compiler = genCompiler(fakeMimosaConfig, compilerImpl);
    var i = 0;
    utils.test.registration( compiler, function() {
      if (++i === 11) {
        done();
      }

      // should not get here
      if (i > 11) {
        expect(false).to.be.true;
      }
    });
  });

  it("will not register for client library functions", function(done) {
    var mimosaConfig = utils.fake.mimosaConfig();
    mimosaConfig.template.writeLibrary = false;
    var compilerImpl = fakeTemplateCompilerImpl()
    var compiler = genCompiler(mimosaConfig, compilerImpl);
    var i = 0;
    utils.test.registration( compiler, function() {
      if (++i === 8) {
        done();
      }

      if (i > 8) {
        // should not get here
        expect(false).to.be.true;
      }
    }, null, mimosaConfig);

  });

  it("will keep a handle on mimosa-require module if it is available", function() {
    compilerImpl = fakeTemplateCompilerImpl();
    mimosaConfig = utils.fake.mimosaConfig();
    mimosaConfig.installedModules['mimosa-require'] = "foo"
    compiler = genCompiler(mimosaConfig, compilerImpl);
    compiler.registration(mimosaConfig, function(){});
    expect(compiler.requireRegister).to.eql("foo");
  });

  describe("when gathering files", function() {
    it("will move to next workflow step if not a template file");
    it("will exit workflow entirely if no files are gathered");
    it("will gather files if file being processed matches folder");
    it("will not gather files if file being processed matches no folder");
    it("will gather files if not processing file");
    it("will gather files from multiple output configs");
    it("will not include the same file twice");
    it("will not gather file types that do not match compiler extensions");
    it("will generate list of files with inputFileNames for apppriate files");
  });

  describe("when compiling", function() {
    it("will execute callback immediately if is not template file");
    it("will execute callback immediately if there are no files");
    it("will generate a template name for each file");
    it("will call compiler compile function for each file");
    it("will generate error message for templates that fail compile");
    it("will add template namespacing when configured");
    it("will not add template namespacing when configured");
    it("will set output text to compiled result");
    it("will not let failed template continue processing");
    it("will allow successful templates to continue processing");
    it("will execute callback after all files compiled");
  });

  describe("when merging templates", function() {
    it("will execute callback immediately if is not template file");
    it("will execute callback immediately if there are no files");
    it("wrap merged file in prefix and suffix");
    it("will not perform any merging if file not in a folder in config");
    it("will include the template preamble in the merged template");
    it("will not include preamle if its optimized build");
    it("will merge files from included folders");
    it("will not merge files from folders not a part of the config");
    it("will test for templates having the same name");
    it("will not create output file if no text");
    it("will create an output file")
  });

  describe("when removing files", function() {
    it("will remove client libraries");
    it("will remove merged libraries");
    it("will call lifecycle callback once when no template library");
    it("will call lifecycle callback once when a template library");
  });

  describe("when testing to remove files", function() {
    it("will execute callback immediately if is not template file");
    it("will not call remove files if there are files");
    it("will call remove files if is template file and has files left")
  });

  describe("when reading client library", function() {
    it("will execute callback immediately if is not template file");
    it("will not readFile in if no clientPath or clientPath does not exist");
    it("will read in and add client library to output files")
  });

  describe("when determining a library path", function() {
    it("if no mimosa-require module will use lib path");
    describe("if mimosa-require is available", function() {
      it("will use alias for path if available");
      it("will use alias for path if prefixed with dot slash");
      it("will use lib path no alias found")
    });
  })
});