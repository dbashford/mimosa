var path = require( "path" );

// Can't run these on travis as mimosa is not installed there
if (__dirname.indexOf("/travis/") < 0) {
  require("./integrations/util/cleaner-test");
}