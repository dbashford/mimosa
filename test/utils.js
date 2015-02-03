var crypto = require( "crypto" )
  , path = require( "path" )
  , _ = require( 'lodash' )
  , fakeMimosaConfigObj = {
    watch: {
      compiledDir:"foo",
      sourceDir:"bar"
    },
    extensions: {
      javascript:["js", "coffee"],
      css:["less"],
      template:["hog", "hogan"],
      copy:["html", "htm"],
      misc:["foo"]
    },
    log: {
      success: function(msg, opts){},
      warn: function(msg, opts){},
      error: function(msg, opts){}
    },
    vendor: {
      javascripts: "javascripts/vendor",
      stylesheets: "stylesheets/vendor"
    }
  }
  ;

var randomString = function( num ) {
  return crypto.randomBytes(num || 64).toString('hex');
};

var fileFixture = function() {
  var fixture = {
    inputFileName: path.join( __dirname, "tmp", randomString(3) + ".js" ),
    inputFileText: randomString(),
    outputFileName: path.join( __dirname, "tmp", randomString(3) + "fixture_outtest1.js" ),
    outputFileText: randomString()
  };

  return fixture;
};

var fakeMimosaConfig = function() {
  return _.cloneDeep(fakeMimosaConfigObj);
};

var testRegistration = function( mod, cb, noExtensions ) {
  var workflows, step, writeFunction, extensions;

  mod.registration( fakeMimosaConfig(), function( _workflows, _step , _writeFunction, _extensions ) {
    workflows = _workflows;
    step = _step;
    writeFunction = _writeFunction;
    extensions = _extensions;

    expect( workflows ).to.be.instanceof( Array );
    expect( step ).to.be.a( "string" );
    expect( writeFunction ).to.be.instanceof( Function )
    if ( !noExtensions ) {
      expect( extensions ).to.be.instanceof( Array );
    }

    cb( writeFunction );
  });
};

module.exports = {
  fileFixture: fileFixture,
  fakeMimosaConfig: fakeMimosaConfig,
  testRegistration: testRegistration
};