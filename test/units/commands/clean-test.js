var path = require( "path" )
  , utils = require( "../../utils" )
  , cleanCommandPath = path.join( process.cwd(), "lib", "command", "clean" )
  , cleanCommand = require( cleanCommandPath )
  ;

describe("Mimosa's clean command", function() {
  utils.test.command.flags.help( cleanCommand );
});
