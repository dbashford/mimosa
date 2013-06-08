var all, logger, program, version;

program = require('commander');

logger = require('logmimosa');

version = require('../package.json').version;

program.version(version);

all = function() {
  require('./command/new')(program);
  require('./command/watch')(program);
  require('./command/config')(program);
  require('./command/build')(program);
  require('./command/clean')(program);
  require('./command/refresh')(program);
  require('./command/virgin')(program);
  require('./command/external')(program);
  require('./command/module/install')(program);
  require('./command/module/init')(program);
  require('./command/module/uninstall')(program);
  require('./command/module/list')(program);
  require('./command/module/search')(program);
  return require('./command/module/config')(program);
};

if (process.argv.length === 2 || (process.argv.length > 2 && process.argv[2] === '--help')) {
  process.argv[2] = '--help';
  all();
} else {
  if (process.argv[2] === "new") {
    require('./command/new')(program);
  } else if (process.argv[2].indexOf("mod:") === 0) {
    require('./command/module/install')(program);
    require('./command/module/init')(program);
    require('./command/module/uninstall')(program);
    require('./command/module/list')(program);
    require('./command/module/search')(program);
    require('./command/module/config')(program);
  } else if (process.argv[2] === "watch") {
    require('./command/watch')(program);
  } else {
    require('./command/config')(program);
    require('./command/build')(program);
    require('./command/clean')(program);
    require('./command/refresh')(program);
    require('./command/virgin')(program);
    require('./command/external')(program);
    program.command('*').action(function(arg) {
      if (arg) {
        logger.red("  " + arg + " is not a valid command.");
      }
      process.argv[2] = '--help';
      all();
      return program.parse(process.argv);
    });
  }
}

program.parse(process.argv);
