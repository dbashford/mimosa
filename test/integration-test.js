var path = require( "path" );
process.setMaxListeners(100);
require("./integrations/util/cleaner-test");
require("./integrations/util/watcher-test");
require("./integrations/commands/build-test");

