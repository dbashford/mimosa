var path = require( "path" )
  , utils = require( "../../utils" )
  , buildCommandPath = path.join( process.cwd(), "lib", "command", "build" )
  , buildCommand = require( buildCommandPath )
  ;

describe("Mimosa's build command", function() {
  utils.test.command.flags.help( buildCommand );
});
