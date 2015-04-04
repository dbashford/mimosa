var path = require( "path" )
  , fs = require( "fs" )
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
    var compiler
      , compilerImpl
      , options = { isTemplateFile: true, files:[{inputFileName:"/foo/templates/templ.tpl"}]}
      ;

    before(function() {
      compilerImpl = fakeTemplateCompilerImpl();
      compilerImpl.compile = function(a, b, done) {
        done();
      };
      compiler = genCompiler(mimosaConfig, compilerImpl);
    });

    it("will create template names based on the name of the file", function(done) {
      var mimosaConfig = utils.fake.mimosaConfig();
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].templateName).to.eql("templ");
        done();
      });
    });

    it("will create template names based on full file path", function(done) {
      var mimosaConfig = utils.fake.mimosaConfig();
      mimosaConfig.template.nameTransform = "filePath"
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].templateName).to.eql("foo/templates/templ");
        done();
      });
    });

    it("will create template names based on full file path and will switch slashes around", function(done) {
      var mimosaConfig = utils.fake.mimosaConfig();
      mimosaConfig.template.nameTransform = "filePath";
      path.sep = "\\";
      var options = { isTemplateFile: true, files:[{inputFileName:"\\foo\\templates\\templ.tpl"}]}
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].templateName).to.eql("foo/templates/templ");
        path.sep = "/";
        done();
      });
    });

    it("will create template names base on transform regex", function(done) {
      var mimosaConfig = utils.fake.mimosaConfig();
      mimosaConfig.template.nameTransform = /.*\/templates\//
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].templateName).to.eql("templ");
        done();
      });
    });

    it("will create template names based on transform function", function(done) {
      var mimosaConfig = utils.fake.mimosaConfig();
      mimosaConfig.template.nameTransform = function(tpl) {
        return tpl + ".transformed";
      };
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].templateName).to.eql("foo/templates/templ.transformed");
        done();
      });
    });

    it("will error out if name created isn't a string", function(done) {
      var spy = sinon.spy(logger, "error");
      var mimosaConfig = utils.fake.mimosaConfig();
      mimosaConfig.template.nameTransform = function(tpl) {
        return {template:"foo"};
      };
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].templateName).to.eql("nameTransformFailed");
        expect(spy.calledOnce).to.be.true;
        logger.error.restore();
        done();
      });
    });

  });

  describe("will remove client library and execute callback", function() {
    var unlinkSpy
      , mimosaConfig = utils.fake.mimosaConfig()
      , compiler
      ;

    before(function() {
      unlinkStub = sinon.stub(fs, "unlink", function(a, done){
        done();
      });
      mimosaConfig.template.output = [];
      compilerImpl = fakeTemplateCompilerImpl();
      compiler = genCompiler(mimosaConfig, compilerImpl);
    });

    afterEach(function() {
      unlinkStub.reset();
    });

    after(function() {
      fs.unlink.restore();
    });

    describe("but will not remove library", function() {
      it("if no client path", function(done) {
        var existsSpy = sinon.spy(fs, "exists");
        var clientPath = compiler.clientPath;
        compiler.clientPath = null;
        compiler._removeFiles( mimosaConfig, {}, function() {
          expect(unlinkStub.callCount).to.eql(0);
          expect(existsSpy.callCount).to.eql(0);
          fs.exists.restore();
          compiler.clientPath = clientPath;
          done();
        });
      });

      it("if client path does not exist", function(done) {
        var existsSpy = sinon.stub(fs, "exists", function(a, cb) {
          cb(false);
        });
        compiler._removeFiles( mimosaConfig, {}, function() {
          expect(unlinkStub.callCount).to.eql(0);
          fs.exists.restore();
          done()
        });
      });
    });

    it("if client path exists", function(done) {
      var existsSpy = sinon.stub(fs, "exists", function(a, cb) {
        cb(true);
      })

      compiler._removeFiles( mimosaConfig, {}, function() {
        expect(unlinkStub.callCount).to.eql(1);
        fs.exists.restore();
        done()
      });
    })
  });

  it("will notify the user if templates have the same name", function(done) {
    var loggerSpy = sinon.spy(logger, "error");
    mimosaConfig = utils.fake.mimosaConfig();
    mimosaConfig.template.output = [{
      folders:["/foo"]
    }]
    compilerImpl = fakeTemplateCompilerImpl();
    compiler = genCompiler(mimosaConfig, compilerImpl);
    var options = {
      isTemplateFile: true,
      files:[{
        inputFileName:"/foo/templates/templ.tpl",
        outputFileText:"output1"
      },{
        inputFileName:"/foo/templates/more/templ.tpl",
        outputFileText:"output2"
      }],
      destinationFile: function() {
        return "destinationFile";
      }
    };
    compiler._merge(mimosaConfig, options, function() {
      expect(loggerSpy.callCount).to.eql(1);
      expect(loggerSpy.args[0][0].match(/templ.tpl/g).length).to.eql(2)
      logger.error.restore();
      done();
    })
  });

  it("will incorporate a template preamble with useful template information", function(done) {
    mimosaConfig = utils.fake.mimosaConfig();
    mimosaConfig.template.output = [{
      folders:["/foo"]
    }]
    var options = {
      isTemplateFile: true,
      files:[{
        inputFileName:"/foo/templates/templ.tpl",
        outputFileText:"output1"
      }],
      destinationFile: function() {
        return "destinationFile";
      }
    };
    compiler._merge(mimosaConfig, options, function() {
      expect(/Source file/.test(options.files[1].outputFileText)).to.eql(true);
      expect(/Template name/.test(options.files[1].outputFileText)).to.eql(true);
      done();
    })
  });

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
    var compiler
      , mimosaConfig
      , compilerImpl
      ;

    before(function() {
      compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      mimosaConfig.vendor.javascripts = path.join(__dirname, mimosaConfig.vendor.javascripts);
      mimosaConfig.watch.sourceDir = path.join(__dirname);
      mimosaConfig.watch.compiledDir = path.join("public");
    })

    afterEach(function() {
      mimosaConfig.template.wrapType = "amd";
      mimosaConfig.template.writeLibrary = true;
      compilerImpl.clientLibrary = "foo.js";
    })

    describe("will set up paths", function() {

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
      });

      it("with writeLibrary turned off", function() {
        mimosaConfig.template.writeLibrary = false; //set back
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
      });
    });

    describe("will not set up paths", function() {

      it("if no client lirbary", function() {
        compilerImpl.clientLibrary = false;
        compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.be.undefined;
        expect(compiler.clientPath).to.be.undefined;
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