var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , fileUtils = require( path.join(process.cwd(), "lib", "util", "file") )
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
      var output = "this is a result";
      if (file.inputFileText) {
        output = file.inputFileText + output;
      }
      cb(null, output);
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

var getInit = function(comp, config, cb) {
  var haveInit = false;
  compiler.registration( config, function(a, b, lifecycle, d) {
    // is first callback
    if (!haveInit) {
      cb(lifecycle);
      haveInit = true;
    }
  });
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
    var mimosaConfig
      , init
      , options = {}
      ;

    before(function(done) {
      var compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      var compiler = genCompiler(mimosaConfig, compilerImpl);
      getInit(compiler, mimosaConfig, function(_init) {
        init = _init
        done();
      });
    });

    it("for matching folders", function(done) {
      mimosaConfig.template.output = [{
        folders:["/foo"],
        outputFileName:"boss"
      }, {
        folders:["/bar"],
        outputFileName:"princess"
      }];

      init(mimosaConfig, options, function() {
        expect(options.destinationFile).to.be.function;
        var destFile = options.destinationFile("nothing", mimosaConfig.template.output[0].folders);
        expect(destFile).to.eql("foo/boss.js")
        done();
      });
    });

    it("for a specific compiler name", function(done) {
      mimosaConfig.template.output = [{
        folders:["/foo"],
        outputFileName:{
          jade: "bossss"
        }
      }, {
        folders:["/bar"],
        outputFileName:"princess"
      }];

      init(mimosaConfig, options, function() {
        expect(options.destinationFile).to.be.function;
        var destFile = options.destinationFile("jade", mimosaConfig.template.output[0].folders);
        expect(destFile).to.eql("foo/bossss.js")
        done();
      });
    });
  });

  describe("during initialization", function() {
    var mimosaConfig
      , init
      , options = {}
      ;

    before(function(done) {
      var compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      var compiler = genCompiler(mimosaConfig, compilerImpl);
      getInit(compiler, mimosaConfig, function(_init) {
        init = _init
        done();
      });
    });

    it("will claim a file if it is inside one of the folders from the config", function(done) {
      mimosaConfig.template.output = [{
        folders:["/bar"],
        outputFileName:"princess"
      }];

      options.inputFile = "/bar/inputfile.js"
      init(mimosaConfig, options, function() {
        expect(options.isTemplateFile).to.be.true;
        expect(options.destinationFile).to.be.function;
        options.inputFile = null;
        done();
      });
    });

    it("will claim extension if being processed", function(done) {
      init(mimosaConfig, options, function() {
        expect(options.isTemplateFile).to.be.true;
        expect(options.destinationFile).to.be.function;
        done();
      });
    });
  });

  describe("when instantiated", function() {
    var mimosaConfig
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
        var compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
      });

      it("with wrapType set to something else", function() {
        mimosaConfig.template.wrapType = "foo";
        var compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
      });

      it("with writeLibrary turned off", function() {
        mimosaConfig.template.writeLibrary = false; //set back
        var compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.eql("vendor/foo");
        expect(compiler.clientPath).to.eql("public/javascripts/vendor/foo.js");
      });
    });

    describe("will not set up paths", function() {

      it("if no client lirbary", function() {
        compilerImpl.clientLibrary = false;
        var compiler = genCompiler(mimosaConfig, compilerImpl);
        expect(compiler.libPath).to.be.undefined;
        expect(compiler.clientPath).to.be.undefined;
      });

      it("if wrap type is not AMD and writeLibrary is turned off", function() {
        mimosaConfig.template.wrapType = "foo";
        mimosaConfig.template.writeLibrary = false;
        var compiler = genCompiler(mimosaConfig, compilerImpl);
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
    var mimosaConfig
      , compiler
      , gatherFileStub
      ;

    before(function() {
      var compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      compiler = genCompiler(mimosaConfig, compilerImpl);
      gatherFileStub = sinon.stub(compiler, "__gatherFolderFilesForOutputFileConfig", function(){});
    });

    after(function() {
      compiler.__gatherFolderFilesForOutputFileConfig.restore()
    });

    afterEach(function() {
      gatherFileStub.reset();
    })

    it("will move to next workflow step if not a template file", function(done) {
      var options = { isTemplateFile: false };
      compiler._gatherFiles( mimosaConfig, options, function() {
        // is called with boolean, 1 param, when exiting normally
        expect(arguments.length).to.eql(0);
        done();
      })
    });

    it("will exit workflow entirely if no files are gathered", function(done) {
      var options = { isTemplateFile: true };
      mimosaConfig.template.output = [];
      compiler._gatherFiles( mimosaConfig, options, function() {
        // is called with boolean, 1 param, when exiting normally
        expect(arguments.length).to.eql(1);
        expect(gatherFileStub.callCount).to.eql(0);
        done();
      });
    });

    it("will gather files if file being processed matches folder", function(done) {
      var options = { isTemplateFile: true };
      mimosaConfig.template.output = [{
        folders:["/foo"]
      }];
      options.inputFile = "/foo/file-inside-foo.js"
      compiler._gatherFiles( mimosaConfig, options, function() {
        // is called with boolean, 1 param, when exiting normally
        expect(gatherFileStub.callCount).to.eql(1);
        done();
      });
    });

    it("will not gather files if file being processed matches no folder", function(done){
      var options = { isTemplateFile: true };
      mimosaConfig.template.output = [{
        folders:["/foo"]
      }];
      options.inputFile = "/bar/file-inside-foo.js"
      compiler._gatherFiles( mimosaConfig, options, function() {
        // is called with boolean, 1 param, when exiting normally
        expect(gatherFileStub.callCount).to.eql(0);
        done();
      });
    });

    it("will gather files if not processing file", function(done) {
      var options = { isTemplateFile: true };
      mimosaConfig.template.output = [{
        folders:["/foo"]
      }];
      compiler._gatherFiles( mimosaConfig, options, function() {
        // is called with boolean, 1 param, when exiting normally
        expect(gatherFileStub.callCount).to.eql(1);
        done();
      });
    });

    it("will gather files from multiple output configs", function(done) {
      var options = { isTemplateFile: true };
      mimosaConfig.template.output = [{
        folders:["/foo"]
      }, {
        folders:["/foo"]
      }];
      options.inputFile = "/foo/file-inside-foo.js"
      compiler._gatherFiles( mimosaConfig, options, function() {
        // is called with boolean, 1 param, when exiting normally
        expect(gatherFileStub.callCount).to.eql(2);
        done();
      });
    });
  });

  describe("when files are gathered", function() {
    var mimosaConfig
      , compiler
      ;

    before(function() {
      var compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      compiler = genCompiler(mimosaConfig, compilerImpl);
    });

    var test = function(spec, files, count, extraTest) {
      it(spec, function(done) {
        sinon.stub(fileUtils, "readdirSyncRecursive", function() {
          return files;
        });
        var options = { isTemplateFile: true };
        mimosaConfig.template.output = [{
          folders:["/foo"]
        }];
        options.inputFile = "/foo/file-inside-foo.js"
        compiler._gatherFiles( mimosaConfig, options, function() {
          // is called with boolean, 1 param, when exiting normally
          expect(options.files.length).to.eql(count);
          fileUtils.readdirSyncRecursive.restore();
          if (extraTest) {
            extraTest(options.files);
          }
          done();
        });
      });
    }

    test("will not include the same file twice",
      ["/foo/file1.hbs", "/foo/file2.hbs", "/foo/file2.hbs"],
      2);
    test("will not gather file types that do not match compiler extensions",
      ["/foo/file1.js", "/foo/file2.js", "/foo/file2.js"],
      0);
    test("will generate list of files with inputFileNames for apporiate files",
      ["/foo/file1.hbs", "/foo/file2.hbs", "/foo/file2.hbs"],
      2,
      function(files) {
        expect(files[0].inputFileName).to.eql("/foo/file1.hbs");
        expect(files[1].inputFileName).to.eql("/foo/file2.hbs");
      });
  });

  describe("when compiling", function() {
    var mimosaConfig
      , compiler
      , compilerImpl
      ;

    before(function() {
      compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      compiler = genCompiler(mimosaConfig, compilerImpl);
    });

    it("will execute callback immediately if is not template file", function(done) {
      var options = { isTemplateFile: false, options: { files: [{inputFileName:"foo", inputFileText:"bar"}]} }
      var compileSpy = sinon.spy( compilerImpl, "compile");
      compiler._compile(mimosaConfig, options, function() {
        expect(compileSpy.callCount).to.eql(0);
        compilerImpl.compile.restore();
        done();
      });
    });

    it("will execute callback immediately if there are no files", function(done) {
      var options = { isTemplateFile: true, files: [] };
      var compileSpy = sinon.spy( compilerImpl, "compile");
      compiler._compile(mimosaConfig, options, function() {
        expect(compileSpy.callCount).to.eql(0);
        compilerImpl.compile.restore();
        done();
      });
    });

    it("will generate a template name for each file", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs"},
          {inputFileName: "/foo/foo.hbs"}
        ]
      };
      var i = 0;
      sinon.stub( compilerImpl, "compile", function() {
        if (++i === 2) {
          expect(options.files[0].templateName).to.eql("bar");
          expect(options.files[1].templateName).to.eql("foo");
          compilerImpl.compile.restore();
          done();
        }
      });
      compiler._compile(mimosaConfig, options, function() {});
    });

    it("will call compiler compile function for each file", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs"},
          {inputFileName: "/foo/foo.hbs"}
        ]
      };
      var compileSpy = sinon.spy( compilerImpl, "compile" );
      compiler._compile(mimosaConfig, options, function() {
        expect( compileSpy.callCount ).to.eql(2);
        compilerImpl.compile.restore();
        done();
      });
    });

    it("will generate error message for templates that fail compile and will exit build", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs"},
          {inputFileName: "/foo/foo.hbs"}
        ]
      };

      var oldCompile = compilerImpl.compile;
      compilerImpl.compile = function( config, file, cb) {
        cb("ERRORERRORERROR", "this is a result");
      };

      var loggerSpy = sinon.spy(logger, "error");
      compiler._compile(mimosaConfig, options, function() {
        expect(loggerSpy.callCount).to.eql(2);
        expect(loggerSpy.args[0][0]).to.eql("Template [[ /foo/bar.hbs ]] failed to compile. Reason: ERRORERRORERROR");
        expect(loggerSpy.args[1][0]).to.eql("Template [[ /foo/foo.hbs ]] failed to compile. Reason: ERRORERRORERROR");
        expect(loggerSpy.args[0][1]).to.eql( {exitIfBuild: true } );
        expect(loggerSpy.args[1][1]).to.eql( {exitIfBuild: true } );
        compilerImpl.compile = oldCompile;
        logger.error.restore();
        done();
      });
    });

    it("will add template namespacing when configured", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs",
           inputFileText: "foo"},
          {inputFileName: "/foo/foo.hbs",
           inputFileText: "bar"}
        ]
      };
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].outputFileText.indexOf("templates[")).to.eql(0);
        expect(options.files[1].outputFileText.indexOf("templates[")).to.eql(0)
        done();
      });
    });

    it("will not add template namespacing when configured", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs",
           inputFileText: "foo"},
          {inputFileName: "/foo/foo.hbs",
           inputFileText: "bar"}
        ]
      };
      compilerImpl.handlesNamespacing = true;
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].outputFileText.indexOf("templates[")).to.eql(-1);
        expect(options.files[1].outputFileText.indexOf("templates[")).to.eql(-1)
        compilerImpl.handlesNamespacing = false;
        done();
      });
    });

    it("will set output text to compiled result", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs",
           inputFileText: "foo"},
          {inputFileName: "/foo/foo.hbs",
           inputFileText: "bar"}
        ]
      };
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files[0].outputFileText).to.eql("templates['bar'] = foothis is a result\n");
        expect(options.files[1].outputFileText).to.eql("templates['foo'] = barthis is a result\n")
        done();
      });
    });

    it("will not let failed template continue processing", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs",
           inputFileText: "foo"},
          {inputFileName: "/foo/foo.hbs",
           inputFileText: "bar"}
        ]
      };

      var oldCompile = compilerImpl.compile;
      var i = 0
      compilerImpl.compile = function( config, file, cb) {
        if (i++ === 0) {
          cb("ERRORERRORERROR", null);
        } else {
          cb(null, "this is a result");
        }
      };
      compiler._compile(mimosaConfig, options, function() {
        expect(options.files.length).to.eql(1);
        compilerImpl.compile = oldCompile;
        done();
      });
    });
  });

  describe("when merging templates", function() {
    var mimosaConfig
      , compiler
      , compilerImpl
      ;

    before(function() {
      compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      compiler = genCompiler(mimosaConfig, compilerImpl);
    });

    afterEach(function() {
      mimosaConfig.template.output = undefined;
      mimosaConfig.isOptimize = false;
    })

    it("will execute callback immediately if is not template file", function(done) {
      var options = { isTemplateFile: false, options: { files: [{inputFileName:"foo", inputFileText:"bar"}]} }
      var libPathSpy = sinon.spy( compiler, "__libraryPath");
      compiler._compile(mimosaConfig, options, function() {
        expect(libPathSpy.callCount).to.eql(0);
        compiler.__libraryPath.restore();
        done();
      });
    });

    it("will execute callback immediately if there are no files", function(done) {
      var options = { isTemplateFile: true, files: [] };
      var libPathSpy = sinon.spy( compiler, "__libraryPath");
      compiler._merge(mimosaConfig, options, function() {
        expect(libPathSpy.callCount).to.eql(0);
        compiler.__libraryPath.restore();
        done();
      });
    });

    describe("in typical merge", function() {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs",
           inputFileText: "foo",
           templateName:"bar",
           outputFileText: "foo output text\n"},
          {inputFileName: "/foo/foo.hbs",
           templateName:"foo",
           inputFileText: "foo",
           outputFileText: "bar output text\n"},
          {inputFileName: "/baz/baz.hbs",
           templateName:"baz",
           inputFileText: "baz",
           outputFileText: "should not be included\n"}
        ],
        destinationFile: function() {
          return "destinationFile";
        }
      };

      before(function(done) {
        mimosaConfig.template.output = [{
          folders:["/foo"],
          outputFileName:"boss"
        }, {
          folders:["/bar"],
          outputFileName:"princess"
        }];

        compiler._merge(mimosaConfig, options, function() {
          done();
        });
      });

      after(function() {
        mimosaConfig.template.output = undefined;
      });

      it("will wrap merged file in prefix and suffix", function() {
        var output = options.files[3].outputFileText;
        expect(output.indexOf("PREFIX")).to.eql(0);
        expect(output.indexOf("SUFFIX")).to.eql(output.length - 6);
      });

      it("will create an output file", function() {
        var outputFile = options.files[3];
        expect(outputFile).to.be.object;
        expect(outputFile.outputFileName).to.eql("destinationFile");
        expect(outputFile.outputFileText).to.be.string;
      });

      it("will include the template preamble in the merged template", function() {
        var outputFile = options.files[3];
        expect(outputFile.outputFileText.match(/Source file/g).length).to.eql(2);
      });

      it("will merge files from included folders only", function() {
        var outputFile = options.files[3];
        // included is text from omitted folder
        expect(outputFile.outputFileText.match(/included/g)).to.be.null;
      });

    });

    it("will not perform any merging if file not in a folder in config", function(done) {
      mimosaConfig.template.output = [{
        folders:["/bar"],
        outputFileName:"boss"
      }];
      var options = {
        inputFile: "/foo/file.hbs",
        isTemplateFile: true,
        files: [
          {inputFileName: "/bar/bar.hbs",
           inputFileText: "foo",
           templateName:"bar",
           outputFileText: "foo output text\n"},
        ],
        destinationFile: function() {
          return "destinationFile";
        }
      };
      compiler._merge(mimosaConfig, options, function() {
        expect(options.files.length).to.eql(1); // would be 2 if file was included
        done();
      });
    });

    it("will test for templates having the same name", function(done) {
      mimosaConfig.template.output = [{
        folders:["/bar"],
        outputFileName:"boss"
      }];
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/bar/foo/bar.hbs",
           inputFileText: "foo",
           templateName:"bar",
           outputFileText: "foo output text\n"},
          {inputFileName: "/bar/bar.hbs",
           inputFileText: "foo",
           templateName:"bar",
           outputFileText: "foo output text\n"}
        ],
        destinationFile: function() {
          return "destinationFile";
        }
      };
      var loggerSpy = sinon.spy(logger, "error");
      compiler._merge(mimosaConfig, options, function() {
        expect(loggerSpy.calledOnce).to.be.true;
        expect(loggerSpy.args[0][0].match(/bar.hbs/g).length).to.eql(2)
        logger.error.restore();
        done();
      });
    });

    it("will not include preamble if its optimized build", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/bar/bar.hbs",
           inputFileText: "foo",
           templateName:"bar",
           outputFileText: "foo output text\n"}
        ],
        destinationFile: function() {
          return "destinationFile";
        }
      };
      mimosaConfig.template.output = [{
        folders:["/bar"],
        outputFileName:"boss"
      }];
      mimosaConfig.isOptimize = true;
      compiler._merge(mimosaConfig, options, function() {
        expect(options.files[1].outputFileText.match(/Source file/g)).to.be.null;
        done();
      });

    });

    it("will not create output file if no text", function(done) {
      var options = {
        isTemplateFile: true,
        files: [
          {inputFileName: "/foo/bar.hbs",
           inputFileText: "foo",
           templateName:"bar",
           outputFileText: ""}
        ],
        destinationFile: function() {
          return "destinationFile";
        }
      };
      mimosaConfig.template.output = [{
        folders:["/bar"],
        outputFileName:"boss"
      }];
      compiler._merge(mimosaConfig, options, function() {
        // no merged file added to files array
        expect(options.files[1]).to.be.undefined;
        done();
      });
    });

  });

  describe("when removing files", function() {
    var mimosaConfig
      , compiler
      , existsStub
      ;

    before(function() {
      // don't want to actually remove anything
      existsStub = sinon.stub(fs, "exists", function(p, cb) {
        cb(false);
      });

      var compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      compiler = genCompiler(mimosaConfig, compilerImpl);
    });

    after(function() {
      fs.exists.restore();
    });

    afterEach(function() {
      fs.exists.reset();
    })

    it("will remove merged libraries", function(done) {
      var options = {
        destinationFile: function() {
          return "destinationFile";
        }
      };
      mimosaConfig.template.output = [{
        folders:["/bar"],
        outputFileName:"boss"
      }];
      compiler._removeFiles(mimosaConfig, options, function() {
        // no merged file added to files array
        expect(existsStub.calledTwice).to.be.true;
        expect(existsStub.args[0][0]).to.eql("javascripts/vendor/foo.js");
        expect(existsStub.args[1][0]).to.eql("foo/boss.js");
        done();
      });
    });

    it("will remove only client library if no output", function(done) {
      var options = {
        destinationFile: function() {
          return "destinationFile";
        }
      };
      mimosaConfig.template.output = [];
      compiler._removeFiles(mimosaConfig, options, function() {
        // no merged file added to files array
        expect(existsStub.calledOnce).to.be.true;
        expect(existsStub.args[0][0]).to.eql("javascripts/vendor/foo.js");
        done();
      });
    });
  });

  describe("when testing to remove files", function() {
    var mimosaConfig
      , compiler
      , removeFilesStub
      ;

    before(function() {
      var compilerImpl = fakeTemplateCompilerImpl();
      mimosaConfig = utils.fake.mimosaConfig();
      compiler = genCompiler(mimosaConfig, compilerImpl);
      removeFilesStub = sinon.stub(compiler, "_removeFiles", function(c, o, n) {
        n();
      });

    });

    after(function() {
      compiler._removeFiles.restore();
    })

    afterEach(function() {
      removeFilesStub.reset();
    });

    it("will execute callback immediately if is not template file", function(done) {
      var options = { isTemplateFile: false, files: [] };
      compiler._testForRemoveClientLibrary( mimosaConfig, options, function() {
        expect(removeFilesStub.callCount).to.eql(0);
        done();
      });
    });

    it("will not call remove files if there are files", function(done) {
      var options = { isTemplateFile: true, files: [{}] };
      compiler._testForRemoveClientLibrary( mimosaConfig, options, function() {
        expect(removeFilesStub.callCount).to.eql(0);
        done();
      });
    });

    it("will call remove files if is template file and has files left", function(done) {
      var options = { isTemplateFile: true, files: [] };
      compiler._testForRemoveClientLibrary( mimosaConfig, options, function() {
        expect(removeFilesStub.callCount).to.eql(1);
        done();
      });
    })
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