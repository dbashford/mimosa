var path = require( "path" );

process.setMaxListeners(100)

// Can't run these on travis as mimosa is not installed there
if (__dirname.indexOf("/travis/") < 0) {
  require("./integrations/util/cleaner-test");
  require("./integrations/util/watcher-test");
}