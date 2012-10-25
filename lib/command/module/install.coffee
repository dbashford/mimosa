path =   require 'path'
fs =     require 'fs'

logger = require 'logmimosa'
{exec} = require 'child_process'

install = (name, opts) ->
  if opts.debug then logger.setDebug()

  unless name.indexOf('mimosa-') is 0
    return logger.error "Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server)."

  currentDir = process.cwd()
  mimosaPath = path.join __dirname, '..', '..'
  process.chdir mimosaPath

  installString = "npm install #{name} --save"
  exec installString, (err, sout, serr) =>
    if err
      logger.error err
    else
      logger.success "Install of '#{name}' successful"

    logger.debug "NPM INSTALL standard out\n#{sout}"
    logger.debug "NPM INSTALL standard err\n#{serr}"
    process.chdir currentDir

register = (program, callback) ->
  program
    .command('mod:install [name]')
    .option("-D, --debug", "run in debug mode")
    .description("install a Mimosa module into your Mimosa")
    .action(callback)
    .on '--help', =>
      logger.green('  The \'mod:install\' command will install a Mimosa module from NPM into Mimosa. This does')
      logger.green('  not install it into your project, it just makes it available to be used by Mimosa\'s ')
      logger.green('  commands.  You can discover new modules using the \'mod:all\' command.  Once you know the')
      logger.green('  module you would like to install, put the name of the module after the \'mod:install\' command.')
      logger.blue( '\n    $ mimosa mod:install mimosa-server\n')
      logger.green('  If there is a specific version of a module you want to use, simply append \'@\' followed by')
      logger.green('  the version information.')
      logger.blue( '\n    $ mimosa mod:install mimosa-server@0.1.0\n')


module.exports = (program) ->
  register program, install