path =   require 'path'
fs =     require 'fs'

wrench = require 'wrench'
logger = require 'logmimosa'

init = (name, opts) ->

  unless name?
    return logger.error "Must provide a module name, ex: mimosa mod:init mimosa-moduleX"

  if name.indexOf('mimosa-') isnt 0
    return logger.error "Your Mimosa module name isn't prefixed with 'mimosa-'.  To work properly with Mimosa, " +
      "modules must be prefixed with 'mimosa-', ex: 'mimosa-moduleX'."

  moduleDirPath = path.resolve(name)
  fs.exists moduleDirPath, (exists) ->
    if exists
      fs.stat moduleDirPath, (err, stats) ->
        if stats.isDirectory()
          logger.info "Directory/file already exists at [[ #{moduleDirPath} ]], placing skeleton inside that directory."
          copySkeleton(name, opts.coffee, moduleDirPath)
        else
          logger.error "File already exists at [[ #{moduleDirPath} ]]"
          process.exit 0
    else
      fs.mkdir moduleDirPath, (err) ->
        if err
          logger.error "Error creating directory: #{err}"
          process.exit 1
        else
          copySkeleton(name, opts.coffee, moduleDirPath)

copySkeleton = (name, isCoffee, moduleDirPath) ->
  lang = if isCoffee then "coffee" else 'js'
  skeletonPath = path.join __dirname, '..', '..', 'modules', 'skeleton', lang
  wrench.copyDirSyncRecursive skeletonPath, moduleDirPath, {excludeHiddenUnix:false}

  gitignore = path.join(moduleDirPath, '.npmignore')
  gitignoreText = fs.readFileSync gitignore, 'ascii'
  fs.writeFileSync path.join(moduleDirPath, '.gitignore'), gitignoreText

  packageJson = path.join(moduleDirPath, 'package.json')
  fs.readFile packageJson, 'ascii', (err, text) ->
    text = text.replace '???', name
    fs.writeFile packageJson, text, (err) ->

      readme = path.join(moduleDirPath, 'README.md')
      fs.readFile readme, 'ascii', (err, text) ->
        text = text.replace /NAMENAMENAME/g, name
        fs.writeFile readme, text, (err) ->
          logger.success "Module skeleton successfully placed in #{name} directory. The first thing you'll" +
                         " want to do is go into #{name}#{path.sep}package.json and replace the placeholders."
          process.exit 0

register = (program, callback) ->
  program
    .command('mod:init [name]')
    .option("-D, --debug", "run in debug mode")
    .option("-c, --coffee", "get a coffeescript version of the skeleton")
    .description("create a Mimosa module skeleton in the named directory")
    .action(callback)
    .on '--help', =>
      logger.green('  The mod:init command will create a directory for the name given, and place a starter')
      logger.green('  module skeleton into the directory.  If a directory for the name given already exists')
      logger.green('  Mimosa will place the module skeleton inside of it.')
      logger.blue( '\n    $ mimosa mod:init [nameOfModule]\n')
      logger.green('  The default skeleton is written in JavaScript.  If you want a skeleton delivered')
      logger.green('  in CoffeeScript add a \'coffee\' flag.')


module.exports = (program) ->
  register program, init