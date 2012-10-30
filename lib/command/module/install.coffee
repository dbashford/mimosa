path =   require 'path'
fs =     require 'fs'
{exec} = require 'child_process'

wrench = require 'wrench'
logger = require 'logmimosa'

install = (name, opts) ->
  if opts.debug then logger.setDebug()

  currentDir = process.cwd()
  mimosaPath = path.join __dirname, '..', '..', '..'

  if name?
    installFromNPM(name, currentDir, mimosaPath)
  else
    logger.info "No name provided, assuming developing module."
    installLocally(currentDir, mimosaPath)

  process.exit 1

installFromNPM = (name, currentDir, mimosaPath) ->
  unless name.indexOf('mimosa-') is 0
    return logger.error "Can only install 'mimosa-' prefixed modules with mod:install (ex: mimosa-server)."

  process.chdir mimosaPath

  installString = "npm install #{name} --save"
  exec installString, (err, sout, serr) =>
    if err
      logger.error err
    else
      console.log ""
      logger.success "Install of '#{name}' successful\n"

    logger.debug "NPM INSTALL standard out\n#{sout}"
    logger.debug "NPM INSTALL standard err\n#{serr}"
    process.chdir currentDir

installLocally = (currentDir, mimosaPath) ->
  try
    pack = require path.join(currentDir, 'package.json')
  catch err
    return logger.error "Unable to find package.json, or badly formatted: #{err}"

  unless pack.name? and pack.version?
    return logger.error "package.json missing either name or version"

  nodemods = path.join mimosaPath, 'node_modules', pack.name

  logger.info "Installing your local module [[ #{pack.name} ]] to [[ #{nodemods} ]]"

  unless fs.existsSync nodemods
    fs.mkdirSync nodemods

  wrench.copyDirSyncRecursive currentDir, nodemods

  process.chdir nodemods
  logger.info "Running NPM Install inside installed module"
  exec "npm install", (err, sout, serr) =>
    if err
      logger.error err
    else
      mimosaPackagePath = path.join mimosaPath, 'package.json'
      mimosaPackage = require(mimosaPackagePath)
      mimosaPackage.dependencies[pack.name] = pack.version
      logger.debug "New mimosa dependencies:\n #{JSON.stringify(mimosaPackage, null, 2)}"
      fs.writeFileSync mimosaPackagePath, JSON.stringify(mimosaPackage, null, 2), 'ascii'

      console.log ""
      logger.success "Install of '#{pack.name}' successful\n"

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
      logger.green('  The \'mod:install\' command will install a Mimosa module into Mimosa. It does not install')
      logger.green('  the module into your project, it just makes it available to be used by Mimosa\'s commands.')
      logger.green('  You can discover new modules using the \'mod:all\' command.  Once you know the module you')
      logger.green('  would like to install, put the name of the module after the \'mod:install\' command.')
      logger.blue( '\n    $ mimosa mod:install mimosa-server\n')
      logger.green('  If there is a specific version of a module you want to use, simply append \'@\' followed by')
      logger.green('  the version information.')
      logger.blue( '\n    $ mimosa mod:install mimosa-server@0.1.0\n')
      logger.green('  If you are developing a module and would like to install your local module into your local')
      logger.green('  Mimosa, then execute \'mod:install\' from the root of the module, the same location as the')
      logger.green('  package.json, without providing a name.  Mimosa will copy the module and install it.')
      logger.blue( '\n    $ mimosa mod:install\n')





module.exports = (program) ->
  register program, install