var path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , wrench = require( "wrench" )
  , logger = require( "logmimosa" )
  , cleanCommandPath = path.join( process.cwd(), "lib", "command", "clean" )
  , cleanCommand = require( cleanCommandPath )
  , utils = require( "../../utils" )
  ;

describe("Mimosa's clean command", function() {

  utils.test.command.flags.missingProfile( "clean" )

  utils.test.command.flags.handlesFlags(
    "clean",
    "--force --cleanall --mdebug",
    "-fCD",
    function(output, projectData, done) {
      expect(output.sout.substring(output.sout.length-17)).to.eql(" already deleted\n")
      done();
    }
  );

  utils.test.command.flags.invalid("clean");
});