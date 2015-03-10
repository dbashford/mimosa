process.setMaxListeners(100);

require("./tests/modules/file/write-test");
require("./tests/modules/file/read-test");
require("./tests/modules/file/init-test");
require("./tests/modules/file/delete-test");
require("./tests/modules/file/clean-test");
require("./tests/modules/file/beforeRead-test");

require("./tests/util/file-test");
require("./tests/util/cleaner-test");
require("./tests/util/watcher-test");

require("./tests/commands/build-test");
require("./tests/commands/clean-test");
require("./tests/commands/watch-test");
require("./tests/commands/external-test");
require("./tests/commands/module/install-test");