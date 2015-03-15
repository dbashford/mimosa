var cp = require( 'child_process' )
  , path = require( "path" )
  , fs = require( "fs" )
  , sinon = require( "sinon" )
  , logger = require( "logmimosa" )
  , modulePath = path.join(process.cwd(), "lib", "modules")
  , moduleMetadata = require(modulePath).installedMetadata
  , commandPath = path.join( process.cwd(), "lib", "command", "module", "list")
  , command = require( commandPath )
  , utils = require( path.join(process.cwd(), "test", "utils"))
  ;

describe("Mimosa's list command", function() {

  utils.test.command.flags.help( command );
  utils.test.command.flags.debugSetup( "modlist", command );

});