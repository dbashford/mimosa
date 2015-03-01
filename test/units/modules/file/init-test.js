var path = require( "path" )
  , sinon = require( "sinon" )
  , utils = require( path.join(process.cwd(), "test", "utils") )
  , initModule = require( path.join(process.cwd(), "lib", "modules", "file", "init") )
  , fakeMimosaConfig = utils.fake.mimosaConfig();
  ;

describe( "Mimosa init workflow module", function(){
  var singleAssetFunction
    , multiAssetFunction;

  before(function(done) {
    var i = 0;
    utils.test.registration( initModule, function( func ) {
      if (i++) {
        singleAssetFunction = func;
        done();
      } else {
        multiAssetFunction = func;
      }
    });
  });

  // css, template processed as extension
  describe( "when invoked with multi-asset", function() {

    var spy;

    before(function() {
      spy = sinon.spy();
    });

    afterEach(function() {
      spy.reset();
    });

    it( "will invoke the lifecycle callback when no files array", function(){
      multiAssetFunction( fakeMimosaConfig, {inputFile:"foo.hog"}, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it( "will have a files array with no files", function(){
      var options = {inputFile:"foo.hog"};
      multiAssetFunction( fakeMimosaConfig, options, spy );
      expect( options.files.length ).to.eql(0);
    });

  });

  // javascript, copy compilers, misc all handled by buildFile
  describe( "when invoked with buildFile asset", function() {

    var spy;

    before(function() {
      spy = sinon.spy();
    });

    afterEach(function() {
      spy.reset();
    });

    it( "will invoke the lifecycle callback when no files array", function(){
      singleAssetFunction( fakeMimosaConfig, {inputFile:"foo.js"}, spy );
      expect( spy.calledOnce ).to.be.true;
    });

    it( "will have a files array with a single entry", function(){
      var options = {
        inputFile:"foo.js",
        extension: "js"
      };
      singleAssetFunction( fakeMimosaConfig, options, function(){} );
      expect( options.files.length ).to.eql(1);
      expect( options.files[0].outputFileName ).to.be.null;
      expect( options.files[0].outputFileText ).to.be.null;
      expect( options.files[0].inputFileText ).to.be.null;
      expect( options.files[0].inputFileName ).to.eql("foo.js");
    });

    describe("will set all the appropriate flags", function() {

      it( "for non-vendor javascript", function() {
        var options = {
          inputFile:"foo.js",
          extension: "js"
        };
        singleAssetFunction( fakeMimosaConfig, options, function(){} );
        expect(options.isJavascript).to.be.true;
        expect(options.isCSS).to.be.false;
        expect(options.isVendor).to.be.false;
        expect(options.isJSNotVendor).to.be.true;
        expect(options.isCopy).to.be.false;
        expect(options.isTemplate).to.be.false;
      });

      it( "for vendor javascript", function() {
        var options = {
          inputFile:"javascripts/vendor/foo.js",
          extension: "js"
        };
        singleAssetFunction( fakeMimosaConfig, options, function(){} );
        expect(options.isJavascript).to.be.true;
        expect(options.isCSS).to.be.false;
        expect(options.isVendor).to.be.true;
        expect(options.isJSNotVendor).to.be.false;
        expect(options.isCopy).to.be.false;
        expect(options.isTemplate).to.be.false;
      });

      it( "for non-vendor css", function() {
        var options = {
          inputFile:"foo.css",
          extension:"css"
        };
        singleAssetFunction( fakeMimosaConfig, options, function(){} );
        expect(options.isJavascript).to.be.false;
        expect(options.isCSS).to.be.true;
        expect(options.isVendor).to.be.false;
        expect(options.isJSNotVendor).to.be.false;
        expect(options.isCopy).to.be.false;
        expect(options.isTemplate).to.be.false;
      });

      it( "for vendor css", function() {
        var options = {
          inputFile:"stylesheets/vendor/foo.css",
          extension:"css"
        };
        singleAssetFunction( fakeMimosaConfig, options, function(){} );
        expect(options.isJavascript).to.be.false;
        expect(options.isCSS).to.be.true;
        expect(options.isVendor).to.be.true;
        expect(options.isJSNotVendor).to.be.false;
        expect(options.isCopy).to.be.false;
        expect(options.isTemplate).to.be.false;
      });

      it( "for a template", function() {
        var options = {
          inputFile:"foo.hog",
          extension:"hog"
        };
        singleAssetFunction( fakeMimosaConfig, options, function(){} );

        expect(options.isJavascript).to.be.true;
        expect(options.isCSS).to.be.false;
        expect(options.isVendor).to.be.false;
        expect(options.isJSNotVendor).to.be.true;
        expect(options.isCopy).to.be.false;
        expect(options.isTemplate).to.be.true;
      });


      it( "for a copied file", function() {
        var options = {
          inputFile:"foo.html",
          extension:"html"
        };
        singleAssetFunction( fakeMimosaConfig, options, function(){} );

        expect(options.isJavascript).to.be.false;
        expect(options.isCSS).to.be.false;
        expect(options.isVendor).to.be.false;
        expect(options.isJSNotVendor).to.be.false;
        expect(options.isCopy).to.be.true;
        expect(options.isTemplate).to.be.false;
      });

    });
  });
});