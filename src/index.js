var program = require('commander')
  , logger =  require('logmimosa')
  , version = require('../package.json').version;

/*
#306 notes
require in config to determine modules
  or ask configurer for modules in config
  possibly just build config up front, allow flag adding
  afterwards.
require('./modules).configured()
allow configuredModules to be easily accessed post creation
refactor all async w/callback out of configurer among other places
*/

program.version(version);
require('./command/new')(program);
require('./command/watch')(program);
require('./command/config')(program);
require('./command/build')(program);
require('./command/clean')(program);
require('./command/external')(program);
require('./command/module/install')(program);
require('./command/module/uninstall')(program);
require('./command/module/list')(program);
require('./command/module/config')(program);

if ((process.argv.length === 2) || (process.argv.length > 2 && process.argv[2] === '--help')) {
  process.argv[2] = '--help';
} else {
  program.command('*').action( function ( arg ) {
    if (arg) {
      logger.red("  " + arg + " is not a valid command.");
    }
    process.argv[2] = '--help';
    program.parse(process.argv);
  });
}

program.parse(process.argv);
