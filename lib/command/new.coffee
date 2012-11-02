path =   require 'path'
{exec} = require 'child_process'
fs =     require 'fs'

wrench = require 'wrench'
_ =      require 'lodash'
logger = require 'logmimosa'

fileUtils = require '../util/file'
util =      require '../util/util'
deps =      require('../../package.json').dependencies
configurer = require '../util/configurer'

class NewCommand

  servers: [
      {name:"none", prettyName:"None - You don't need a server, or you'd like Mimosa to serve your application for you."}
      {name:"express", prettyName:"(*) Express - http://expressjs.com/", isDefault:true}
    ]

  views: [
      {
        name:"jade"
        prettyName:"(*) Jade - http://jade-lang.com/"
        library: "jade"
        extension:"jade"
        isDefault:true
      }
      {
        name:"hogan"
        prettyName:"Hogan - http://twitter.github.com/hogan.js/"
        library: "hogan.js"
        extension:"hjs"
      }
      {
        name:"html"
        prettyName:"Plain HTML"
        library: "ejs"
        extension:"html"
      }
      {
        name:"ejs"
        prettyName:"Embedded JavaScript Templates (EJS) - https://github.com/visionmedia/ejs"
        library: "ejs"
        extension:"ejs"
        version: "0.8.3"
      }
    ]

  constructor: (@program) ->
    for view in @views
      view.version = deps[view.library] unless view.version?

  register: =>
    @program
      .command('new [name]')
      .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .option("-d, --defaults",  "bypass prompts and go with Mimosa defaults (CoffeeScript, Stylus, Handlebars)")
      .option("-D, --debug", "run in debug mode")
      .action(@new)
      .on '--help', @_printHelp

  new: (name, opts) =>
    if opts.debug then logger.setDebug()
    logger.debug "Project name: #{name}"
    logger.green "\n  Determining system capabilities..."

    util.projectPossibilities (compilers) =>
      if opts.defaults
        @_createWithDefaults(compilers, name)
      else
        @_prompting(compilers, name)

  _prompting: (compilers, name) =>
    logger.debug "Compilers :\n#{JSON.stringify(compilers, null, 2)}"

    logger.green "\n  Mimosa will guide you through project creation. You will be prompted to"
    logger.green "  pick the JavaScript meta-language, CSS meta-language, and micro-templating"
    logger.green "  library you would like to use. For more about those choices, see"
    logger.green "  http://mimosajs.com/compilers.html. You will also be prompted to pick the"
    logger.green "  server and server-side view technologies you would like to use. If you pick"
    logger.green "  no server, Mimosa will serve your assets for you.\n"

    logger.green "  For all of the technologies, if your favorite is not an option, you can add"
    logger.green "  a GitHub issue and we'll look into adding it.\n"

    logger.green "  If you are unsure which options to pick, the ones with asterisks are Mimosa"
    logger.green "  favorites. Feel free to hit the web to research your selections, Mimosa will"
    logger.green "  be here when you get back."

    logger.green "\n  To start, please choose your JavaScript meta-language: \n"
    @program.choose _.pluck(compilers.javascript, 'prettyName'), (i) =>
      logger.blue "\n  You chose #{compilers.javascript[i].prettyName}."
      chosen = {javascript: compilers.javascript[i]}
      logger.green "\n  Choose your CSS meta-language:\n"
      @program.choose _.pluck(compilers.css, 'prettyName'), (i) =>
        logger.blue "\n  You chose #{compilers.css[i].prettyName}."
        chosen.css = compilers.css[i]
        logger.green "\n  Choose your micro-templating language:\n"
        @program.choose _.pluck(compilers.template, 'prettyName'),(i) =>
          logger.blue "\n  You chose #{compilers.template[i].prettyName}."
          chosen.template = compilers.template[i]
          logger.green "\n  Choose your server technology:\n"
          @program.choose _.pluck(@servers, 'prettyName'),(i) =>
            logger.blue "\n  You chose #{@servers[i].prettyName}."
            chosen.server = @servers[i]
            logger.green "\n  And finally choose your server view templating library:\n"
            @program.choose _.pluck(@views, 'prettyName'),(i) =>
              logger.blue "\n  You chose #{@views[i].prettyName}."
              chosen.views = @views[i]
              logger.green "\n  Creating and setting up your project... \n"
              @_create(name, chosen)

  _createWithDefaults: (compilers, name) =>
    chosen = {}
    chosen.css =        (compilers.css.filter        (item) -> item.isDefault)[0]
    chosen.javascript = (compilers.javascript.filter (item) -> item.isDefault)[0]
    chosen.template =   (compilers.template.filter   (item) -> item.isDefault)[0]
    chosen.server =     (@servers.filter             (item) -> item.isDefault)[0]
    chosen.views =      (@views.filter               (item) -> item.isDefault)[0]
    @_create(name, chosen)

  _create: (name, chosen) =>
    @config = configurer.buildConfigText()

    skeletonPath = path.join __dirname, '..', 'skeleton'

    # if name provided, simply copy directory into directory by that name
    # if name not provided, copy all skeleton contents into current directory
    @currPath = if name?.length > 0
      @_copySkeletonToProvidedDirectory(skeletonPath, name)
    else
      @_copySkeletonToCurrentDirectory(skeletonPath)

    @_makeChosenCompilerChanges(chosen)

    @_postCopyCleanUp()

    if chosen.server.name is "none"
      @_usingDefaultServer()
    else
      @_usingOwnServer(name, chosen)

    @_usingOwnViews(chosen)

  _copySkeletonToProvidedDirectory: (skeletonPath, name) ->
    currPath = path.join path.resolve(''), name
    logger.info "Copying skeleton project into #{currPath}"
    wrench.copyDirSyncRecursive skeletonPath, currPath
    currPath

  _copySkeletonToCurrentDirectory: (skeletonPath) ->
    logger.info "A project name was not provided, copying skeleton into the current directory"
    currPath = path.join path.resolve(''), path.sep
    @_moveDirectoryContents(skeletonPath)
    currPath

  _moveDirectoryContents: (sourcePath, outPath) ->
    contents = wrench.readdirSyncRecursive(sourcePath)
    for item in contents
      fullSourcePath = path.join sourcePath, item
      fileStats = fs.statSync fullSourcePath
      fullOutPath = path.join(outPath, item)
      if fileStats.isDirectory()
        logger.debug "Copying directory: [[ #{fullOutPath} ]]"
        wrench.mkdirSyncRecursive fullOutPath, 0o0777
      if fileStats.isFile()
        logger.debug "Copying file: [[ #{fullOutPath} ]]"
        fileContents = fs.readFileSync fullSourcePath
        fs.writeFileSync fullOutPath, fileContents

  _makeChosenCompilerChanges: (chosenCompilers) ->
    logger.debug "Chosen compilers:\n#{JSON.stringify(chosenCompilers, null, 2)}"
    @_updateConfigForChosenCompilers(chosenCompilers)
    @_copyCompilerSpecificExampleFiles(chosenCompilers)

  _updateConfigForChosenCompilers: (comps) ->

    # return if all the defaults were chosen
    return if comps.javascript.isDefault and comps.views.isDefault

    replacements = {}
    unless comps.javascript.isDefault
      replacements["# server:"]                 = "server:"
      replacements["# path: 'server.coffee'"]   = "path: 'server.#{comps.javascript.defaultExtensions[0]}'"

    unless comps.views.isDefault
      replacements["# server:"]             = "server:"
      replacements["# views:"]              = "views:"
      replacements["# compileWith: 'jade'"] = "compileWith: '#{comps.views.name}'"
      replacements["# extension: 'jade'"] = "extension: '#{comps.views.extension}'"

    for thiz, that of replacements
      @config = @config.replace thiz, that

  _copyCompilerSpecificExampleFiles: (comps) ->
    safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map (path) ->
      "\\.#{path}$"
    safePaths.push "javascripts[/\\\\]vendor"

    assetsPath = path.join @currPath,  'assets'
    allItems = wrench.readdirSyncRecursive(assetsPath)
    files = allItems.filter (i) -> fs.statSync(path.join(assetsPath, i)).isFile()

    for file in files
      filePath = path.join(assetsPath, file)
      isSafe = safePaths.some (path) -> file.match(path)

      # clear out the bad views
      if isSafe
        if filePath.indexOf('example-view-') >= 0
          unless _.some(comps.template.defaultExtensions, (ext) -> filePath.indexOf("-#{ext}.") >= 0)
            isSafe = false
          else
            templateView = filePath

        isSafe = false if filePath.indexOf('handlebars-helpers') >= 0 and
          not _.some(comps.template.defaultExtensions, (ext) -> ext is "hbs")

      fs.unlink filePath unless isSafe

    serverPath = path.join @currPath,  'servers'
    allItems = wrench.readdirSyncRecursive(serverPath)
    files = allItems.filter (i) -> fs.statSync(path.join(serverPath, i)).isFile()
    for file in files
      filePath = path.join(serverPath, file)
      isSafe = safePaths.some (path) -> file.match(path)
      fs.unlink filePath unless isSafe

    # alter template view name and insert css framework
    if templateView?
      data = fs.readFileSync templateView, "ascii"
      fs.unlink templateView
      cssFramework = if comps.css.base is "none" then "pure CSS" else comps.css.base
      data = data.replace "CSSHERE", cssFramework
      templateView = templateView.replace /-\w+\./, "."
      fs.writeFile templateView, data

  _postCopyCleanUp: =>
    data = fs.readFileSync (path.join @currPath, '.npmignore'), 'ascii'
    logger.debug "Writing .gitignore"
    fs.writeFileSync path.join(@currPath, '.gitignore'), data, 'ascii'

    files = fileUtils.glob "#{@currPath}/**/.gitkeep", {dot:true}
    logger.debug "Removing #{files.length} .gitkeeps"
    fs.unlinkSync(file) for file in files

  _usingOwnViews: (chosen) ->
    logger.debug "Moving views into place"
    @_moveDirectoryContents(path.join(@currPath, "view", chosen.views.name), @currPath)
    wrench.rmdirSyncRecursive path.join(@currPath, "view")

  # remove express files/directories and update config to point to default server
  _usingDefaultServer: ->
    logger.debug "Using default server, so removing server resources"
    fs.unlinkSync path.join(@currPath, "package.json")
    wrench.rmdirSyncRecursive path.join(@currPath, "servers")

    logger.debug "Altering configuration to not use server"
    @config = @config.replace "# server:", "server:"
    @config = @config.replace "# useDefaultServer: false", "useDefaultServer: true"
    @_done()

  _usingOwnServer: (name, chosen) ->
    logger.debug "Making package.json edits"
    jPath = path.join @currPath, "package.json"
    packageJson = require(jPath)
    packageJson.name = name if name?
    packageJson.dependencies[chosen.views.library] = chosen.views.version

    unless chosen.javascript.base is "livescript"
      logger.debug "removing iced-coffee-script from package.json"
      delete packageJson.dependencies["LiveScript"]

    unless chosen.javascript.base is "iced"
      logger.debug "removing iced-coffee-script from package.json"
      delete packageJson.dependencies["iced-coffee-script"]

    unless chosen.javascript.base is "coffee"
      logger.debug "removing coffee-script from package.json"
      delete packageJson.dependencies["coffee-script"]

    fs.writeFileSync jPath, JSON.stringify(packageJson, null, 2)

    logger.debug "Moving server into place"
    @_moveDirectoryContents(path.join(@currPath, "servers", chosen.server.name), @currPath)
    wrench.rmdirSyncRecursive path.join(@currPath, "servers")

    logger.info "Installing node modules"
    currentDir = process.cwd()
    process.chdir @currPath
    exec "npm install", (err, sout, serr) =>
      logger.debug "Node module install err: #{err}"
      logger.debug "Node module install sout: #{sout}"
      logger.debug "Node module install serr: #{serr}"
      process.chdir currentDir
      @_done()

  _done: =>
    configPath = path.join @currPath, "mimosa-config.coffee"
    fs.writeFile configPath, @config, (err) ->
      logger.success "New project creation complete!  Execute 'mimosa watch --server' from inside your project to monitor the file system. Then start coding!"
      process.stdin.destroy()

  _printHelp: ->
    logger.green('  The new command will take you through a series of questions regarding what')
    logger.green('  JavaScript meta-language, CSS meta-language, micro-templating library, server')
    logger.green('  and server view technology you would like to use to build your project. Once')
    logger.green('  you have answered the questions, Mimosa will create a directory using the name')
    logger.green('  you provided, and place a project skeleton inside of it.  That project skeleton')
    logger.green('  will by default include a basic application using the technologies you selected.')
    logger.blue( '\n    $ mimosa new [nameOfProject]\n')
    logger.green('  If you wish to copy the project skeleton into your current directory instead of')
    logger.green('  into a new one leave off the name.')
    logger.blue( '\n    $ mimosa new\n')
    logger.green('  If you are happy with the defaults (CoffeeScript, Stylus, Handlebars, Express, Jade),')
    logger.green('  you can bypass the prompts by providing a \'defaults\' flag.')
    logger.blue( '\n    $ mimosa new [name] --defaults')
    logger.blue( '    $ mimosa new [name] -d\n')

module.exports = (program) ->
  command = new NewCommand(program)
  command.register()