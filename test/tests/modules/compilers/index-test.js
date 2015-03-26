var path = require( "path" )
  , fs = require( "fs" )
  , logger = require( "logmimosa" )
  , sinon = require( "sinon" )
  , validators = require( "validatemimosa" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , compilerManager = require( path.join(process.cwd(), "lib", "modules", "compilers", "index") )
  , JSCompiler = require( path.join(process.cwd(), "lib", "modules", "compilers", "javascript") )
  , CSSCompiler = require( path.join(process.cwd(), "lib", "modules", "compilers", "css") )
  , MiscCompiler = require( path.join(process.cwd(), "lib", "modules", "compilers", "misc") )
  ;

var compiler1 = function() {
  return {
    compilerType: "misc",
    extensions: function() {
      return ["foo", "bar"];
    },
    name: "compiler1"
  };
};

var compiler2 = function() {
  return {
    compilerType: "css",
    extensions: function() {
      return ["css", "sass"];
    },
    name: "compiler2"
  };
};

var compiler3 = function() {
  return {
    compilerType: "javascript",
    extensions: function() {
      return ["js", "coffee"];
    },
    name: "compiler3"
  };
};

var compiler4 = function() {
  return {
    compilerType: "javascript",
    extensions: function() {
      return ["js"];
    },
    name: "compiler4"
  };
};

var nonCompiler = function() {
  return {
    extensions: function() {
      return ["js"];
    },
    name: "compiler5"
  };
};

describe("Mimosa's compiler manager", function() {

  describe("when checking multiple template library use", function() {
    var checkTemplates
      , config
      , loggerSpy;

    before(function(done) {
      loggerSpy = sinon.spy(logger, "error")
      config = utils.fake.mimosaConfig();
      config.template = {
        outputFileName: "foo.js"
      };
      config.extensions.template = ["hbs"]
      compilerManager.registration( config, function(a, b, cb, d){
        checkTemplates = cb;
        done();
      });
    });

    after(function() {
      logger.error.restore();
    })

    it("will catch when multiple template libraries used", function(done) {
      var options = { files: [""]}
      checkTemplates( config, options, function() {
        expect(loggerSpy.calledOnce).to.be.false;
        checkTemplates( config, options, function() {
          expect(loggerSpy.calledOnce).to.be.true;
          done();
        });
      });
    });
    describe("will continue the workflow", function() {
      it("if no template files", function(done) {
        var options = { files: []}
        checkTemplates( config, options, function() {
          // callback being called = win
          expect(true).to.be.true;
          done();
        });
      });
      it("if template object configured", function(done) {
        var options = { files: [""] };
        config.template.outputFileName = {foo:true}
        checkTemplates( config, options, function() {
          // callback being called = win
          expect(true).to.be.true;
          done();
        });
      });
    })
  });

  describe("when setting up compilers", function() {
    describe("will build list of extensions", function() {

      it("when single compiler", function() {
        var extensions = {
          javascript: ['js'],
          css: ['css'],
          template: [],
          copy: [],
          misc:["foo", "bar"]
        };

        var config = utils.fake.mimosaConfig();
        config.installedModules = [compiler1()];
        config.extensions = {
          javascript: ['js'],
          css: ['css'],
          template: [],
          copy: [],
          misc:[]
        };
        compilerManager.setupCompilers(config);
        expect(config.extensions).to.eql(extensions);
      });

      it("when multiple compilers and keep extensions unique", function(){
        var extensions = {
          javascript: ['js', 'coffee'],
          css: ['css', 'sass'],
          template: [],
          copy: [],
          misc:["foo", "bar"]
        };

        var config = utils.fake.mimosaConfig();
        config.installedModules = [compiler1(), compiler2(), compiler3(), compiler4()];
        config.extensions = {
          javascript: ['js'],
          css: ['css'],
          template: [],
          copy: [],
          misc:[]
        };
        compilerManager.setupCompilers(config);
        expect(config.extensions).to.eql(extensions);
      });
    });

    describe("will assemble list of compilers", function() {

      it("and only a list of compilers", function() {
        var config = utils.fake.mimosaConfig();
        config.installedModules = [compiler1(), compiler2(), compiler3(), compiler4(), nonCompiler()];
        compilerManager.setupCompilers(config);
        expect(compilerManager.compilers.length).to.eql(4);
        var comps = compilerManager.compilers.filter(function(comp) {
          return comp.name === "compiler5";
        });
        expect(comps.length).to.eql(0)
      });

      it("and will resort compilers", function() {
        var config = utils.fake.mimosaConfig();
        config.installedModules = [compiler1(), compiler2(), compiler3(), compiler4(), nonCompiler()];
        compilerManager.setupCompilers(config);
        expect(compilerManager.compilers[0].compilerType).to.eql("css");
        expect(compilerManager.compilers[1].compilerType).to.eql("javascript");
        expect(compilerManager.compilers[2].compilerType).to.eql("javascript");
        expect(compilerManager.compilers[3].compilerType).to.eql("misc");
      });

      it("and will not resort compilers if configured not to", function() {
        var config = utils.fake.mimosaConfig();
        config.installedModules = [compiler1(), compiler2(), compiler3(), compiler4(), nonCompiler()];
        config.resortCompilers = false;
        compilerManager.setupCompilers(config);
        expect(compilerManager.compilers[0].compilerType).to.eql("misc");
        expect(compilerManager.compilers[1].compilerType).to.eql("css");
        expect(compilerManager.compilers[2].compilerType).to.eql("javascript");
        expect(compilerManager.compilers[3].compilerType).to.eql("javascript");
      });
    });
  });

  describe("when registering", function() {

    describe("compilers", function() {

      var jsRegistrationSpy
        , cssRegistrationSpy
        , miscRegistrationSpy
        , config
        ;

      before(function() {
        config = utils.fake.mimosaConfig();
        config.installedModules = [compiler1(), compiler2(), compiler3(), compiler4(), nonCompiler()];
        compilerManager.setupCompilers(config);

        jsRegistrationSpy = sinon.spy(JSCompiler.prototype, "registration");
        cssRegistrationSpy = sinon.spy(CSSCompiler.prototype, "registration");
        miscRegistrationSpy = sinon.spy(MiscCompiler.prototype, "registration");

        compilerManager.registration( config, function(){})
      });

      after(function() {
        JSCompiler.prototype.registration.restore();
        CSSCompiler.prototype.registration.restore();
        MiscCompiler.prototype.registration.restore();
      })

      it("will instantiate all the master compilers and pass in the child compilers", function() {
        expect(jsRegistrationSpy.firstCall.thisValue.compiler.name).to.eql("compiler3")
        expect(jsRegistrationSpy.secondCall.thisValue.compiler.name).to.eql("compiler4")
        expect(cssRegistrationSpy.firstCall.thisValue.compiler.name).to.eql("compiler2")
        expect(miscRegistrationSpy.firstCall.thisValue.compiler.name).to.eql("compiler1")
      });

      it("will set the compiler name on the instance", function() {
        expect(jsRegistrationSpy.firstCall.thisValue.name).to.eql("compiler3")
        expect(jsRegistrationSpy.secondCall.thisValue.name).to.eql("compiler4")
        expect(cssRegistrationSpy.firstCall.thisValue.name).to.eql("compiler2")
        expect(miscRegistrationSpy.firstCall.thisValue.name).to.eql("compiler1")
      });

      it("will register the compiler instances", function() {
        expect(jsRegistrationSpy.calledTwice).to.be.true;
        expect(cssRegistrationSpy.calledOnce).to.be.true;
        expect(miscRegistrationSpy.calledOnce).to.be.true;
      });

      it("will call child registration functions if they exist");

    });

    describe("will register", function() {
      var config;

      before(function() {
        config = utils.fake.mimosaConfig();
        config.installedModules = [];
        config.extensions = {
          javascript: ['js'],
          css: ['css'],
          template: [],
          copy: [],
          misc:[]
        };
        compilerManager.setupCompilers(config);
      });

      it("will register the dupe template checker", function(done) {
        config.template = {
          outputFileName: "foo.js"
        };
        config.extensions.template = ["hbs"]
        compilerManager.registration( config, function(a, b, cb, d){
          expect(d).to.eql(["hbs"])
          done();
        });
      });

      it("will not register the dupe template checker if templates are not configured", function(done) {
        config.template = null;
        var spy = sinon.spy();
        compilerManager.registration( config, spy );
        setTimeout(function() {
          expect(spy.callCount).to.eql(0);
          done();
        }, 50);
      });
    });

  });

  it("returns the proper defaults", function() {
    var defaults = compilerManager.defaults();
    expect(defaults).to.be.object;
  });

  describe("validation", function() {
    it("will fail if resortCompilers isnt a boolean", function() {
      var errors = compilerManager.validate({resortCompilers: "false"}, validators)
      expect(errors[0]).to.eql("resortCompilers must be a boolean.");
    });

    it("will fail if template isn't an object", function() {
      var errors = compilerManager.validate({template: "false"}, validators)
      expect(errors[0]).to.eql("template config must be an object.");
    });

    it("will fail if writeLibrary isnt a boolean", function() {
      var errors = compilerManager.validate({template: {writeLibrary: "false"}}, validators)
      expect(errors[0]).to.eql("template.writeLibrary must be a boolean.");
    });

    it("will fail if wrapType isnt a string", function() {
      var errors = compilerManager.validate({template: {wrapType: false}}, validators)
      expect(errors[0]).to.eql("template.wrapType must be a string.");
    });

    it("will fail if wrapType isn't proper setting", function() {
      var errors = compilerManager.validate({template: {wrapType: "foo"}}, validators)
      expect(errors[0]).to.eql("template.wrapType must be one of: 'common', 'amd', 'none'");
    });

    it("will fail if nameTransform isn't string, regex or function", function() {
      var errors = compilerManager.validate({template: {nameTransform: false}}, validators)
      expect(errors[0]).to.eql("config.template.nameTransform property must be a string, regex or function");
    });

    it("will fail if nameTransform is a string and isn't fileName or filePath", function() {
      var errors = compilerManager.validate({template: {nameTransform: "foo"}}, validators)
      expect(errors[0]).to.eql("config.template.nameTransform valid string values are filePath or fileName");
    });

    describe("for template naming", function() {

      before(function() {
        sinon.stub(fs, "existsSync", function() {
          return true;
        })
      });

      after(function() {
        fs.existsSync.restore();
      });

      it("will transform outputFileName into output format", function() {
        var answer = {
          "outputFileName": "javascripts/foo",
          "output": [
            {
              "folders": [
                "bar"
              ],
              "outputFileName": "javascripts/foo"
            }
          ]
        }

        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          outputFileName: "javascripts/foo"
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(fakeMimosaConfig.template).to.eql(answer);
      });

      it("will fail if output.folders is not an array or is an array of length 0", function() {
        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          outputFileName: 3
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(errors[0]).to.eql("template.outputFileName must be an object or a string.");
      });

      it("will fail if output.folders is not an array or is an array of length 0", function() {
        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          output: [{
            folders:"afolder",
            outputFileName:"javascripts/foo"
          }]
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(errors[0]).to.eql("template.output.folders configuration must be an array.");

        fakeMimosaConfig.template = {
          output: [{
            folders:[],
            outputFileName:"javascripts/foo"
          }]
        };
        errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(errors[0]).to.eql("template.output.folders must have at least one entry");
      });

      it("will fail if outputFileName does not exist", function() {
        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          output: [{
            folders:["afolder"]
          }]
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(errors[0]).to.eql("template.output.outputFileName must exist for each entry in array.");
      });

      it("will fail if outputFileName is not an object or string", function() {
        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          output: [{
            folders:["afolder"]
          }]
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(errors[0]).to.eql("template.output.outputFileName must exist for each entry in array.");
      });

      it("will resolve folders to full paths", function() {
        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          output: [{
            folders:["afolder"],
            outputFileName:"yeah"
          }]
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(fakeMimosaConfig.template.output[0].folders[0]).to.eql("bar/afolder");
      });

      it("will build proper output structure", function() {
        var expected = [{
          folders: [ 'bar/afolder' ],
          outputFileName: 'yeah'
        },{
          folders: [ 'bar/anotherfolder', 'bar/commonfolder' ],
          outputFileName: 'javascripts/stuff'
        }];

        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          output: [{
            folders:["afolder"],
            outputFileName:"yeah"
          },{
            folders:["anotherfolder", "commonfolder"],
            outputFileName:"javascripts/stuff"
          }]
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(fakeMimosaConfig.template.output).to.eql(expected);
      });

      it("will fail if a folder doesn't exist on the file system", function() {
        fs.existsSync.restore();
        sinon.stub(fs, "existsSync", function() {
          return false;
        })

        var fakeMimosaConfig = utils.fake.mimosaConfig();
        fakeMimosaConfig.template = {
          output: [{
            folders:["afolder"],
            outputFileName:"javascripts/foo"
          }]
        };
        var errors = compilerManager.validate(fakeMimosaConfig, validators);
        expect(errors[0]).to.eql("template.output.folders must exist, folder resolved to [[ bar/afolder ]]");
        //fs.existsSync.restore();
      });
    });
  });
});