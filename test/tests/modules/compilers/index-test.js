var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , validators = require( "validatemimosa" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , compilerManager = require( path.join(process.cwd(), "lib", "modules", "compilers", "index") )
  ;

describe("Mimosa's compiler manager", function() {

  describe("when checking multiple template library use", function() {
    it("will catch when multiple template libraries used");
    describe("will continue the workflow", function() {
      it("if no template files");
      it("if template object configured");
    })
  });

  describe("when setting up compilers", function() {
    describe("will build list of extensions", function() {
      it("when single compiler");
      it("when multiple compilers");
      it("and not inspect modules that are not compilers");
      it("and will keep extensions per type unique");
      it("and will resort compilers")
    })
  });

  describe("when registering", function() {
    it("will instantiate all the master compilers and pass in the child compilers");
    it("will set the compiler name on the instance");
    it("will register the compiler instances");
    it("will call child registration functions if they exist");
    it("will register the dupe template checker")
    it("will not register the dupe template checker if templates are not configured")
  });

  it("returns the proper defaults");

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
      });
    });
  });
});