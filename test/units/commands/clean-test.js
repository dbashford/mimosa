var path = require( "path" )
  , logger = require( "logmimosa")
  , sinon = require( "sinon" )
  , utils = require( "../../utils" )
  , cleanCommandPath = path.join( process.cwd(), "lib", "command", "clean" )
  , cleanCommand = require( cleanCommandPath )
  ;

describe("Mimosa's clean command", function() {
  var loggerGreenSpy
    , loggerBlueSpy
    ;

  before(function() {
    loggerGreenSpy = sinon.spy(logger, "green");
    loggerBlueSpy = sinon.spy(logger, "blue");
  })

  after(function(){
    logger.green.restore();
    logger.blue.restore();
  });

  it("will print help", function( done ) {

    var program = utils.fake.program();
    program.on = function(flag, cb) {
      expect(flag).to.eql("--help");
      cb();
      expect(loggerGreenSpy.callCount).to.be.above(5);
      expect(loggerBlueSpy.callCount).to.be.above(5);
      done()
      return program;
    };

    cleanCommand( program );
  });

});
