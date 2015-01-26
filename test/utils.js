var crypto = require( "crypto" )
  , path = require( "path" )
  , _ = require( 'lodash' )
  , fakeMimosaConfigObj = {
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

module.exports = {
  fileFixture: fileFixture,
  fakeMimosaConfig: fakeMimosaConfig
};