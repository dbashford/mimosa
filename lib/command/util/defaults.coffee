path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'

logger =   require '../../util/logger'

class MimosaDefaults

  fatalErrors: 0

  applyAndValidateDefaults: (config, configPath, callback) =>
    @root = path.dirname(configPath)
    config = @_applyDefaults(config)
    @_validateSettings(config)
    err = if @fatalErrors is 0
      logger.debug "No mimosa config errors"
      null
    else
      @fatalErrors
    callback(err, config)

  _applyDefaults: (config) ->
    newConfig = {}

    newConfig.virgin =       config.virgin
    newConfig.isServer =     config.isServer
    newConfig.optimize =     config.optimize
    newConfig.min =          config.min
    newConfig.isForceClean = config.isForceClean
    newConfig.javascriptExtensions = ['js']

    newConfig.watch =               config.watch ?= {}
    newConfig.watch.sourceDir =     path.join(@root, config.watch.sourceDir   ? "assets")
    newConfig.watch.compiledDir =   path.join(@root, config.watch.compiledDir ? "public")
    newConfig.watch.javascriptDir = config.watch.javascriptDir ?= "javascripts"
    newConfig.watch.ignored =       config.watch.ignored ?= [".sass-cache"]
    newConfig.watch.throttle =      config.watch.throttle ?= 0

    newConfig.compilers = config.compilers ?= {}
    newConfig.compilers.extensionOverrides = config.compilers.extensionOverrides ?= {}

    template = newConfig.template = config.template ?= {}
    template.outputFileName =  config.template.outputFileName  ?= "javascripts/templates"
    template.helperFiles = []
    helperFiles = config.template.helperFiles ?= ["javascripts/app/template/handlebars-helpers"]
    for helperFile in helperFiles
      template.helperFiles.push path.join(@root, helperFile)

    copy = newConfig.copy = config.copy                        ?= {}
    copy.extensions =       config.copy.extensions             ?= ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]

    requirejs = newConfig.require = config.require             ?= {}

    unless config.virgin
      server = newConfig.server = config.server                   ?= {}
      server.useDefaultServer =   config.server.useDefaultServer  ?= false
      server.port =               config.server.port              ?= 3000
      server.base =               config.server.base              ?= ''
      server.useReload =          config.server.useReload         ?= true
      server.path =               config.server.path              ?= 'server.coffee'
      server.path =               path.join(@root, server.path)
      server.views =              config.server.views             ?= {}
      server.views.compileWith =  config.server.views.compileWith ?= "jade"
      if server.views.compileWith is "html"
        server.views.compileWith = "ejs"
        server.views.html = true
      server.views.extension =    config.server.views.extension   ?= "jade"
      server.views.path =         config.server.views.path        ?= "views"
      server.views.path =         path.join(@root, server.views.path)

      requirejs.optimize = newConfig.require.optimize = config.require.optimize     ?= {}
      requirejs.optimize.inferConfig = config.require.optimize.inferConfig ?= true
      requirejs.optimize.overrides = config.require.optimize.overrides ?= {}

    requirejs.verify = newConfig.require.verify = config.require.verify ?= {}
    requirejs.verify.enabled = config.require.verify.enabled            ?= true

    minify = newConfig.minify =       config.minify             ?= {}
    minify.exclude = config.minify.exclude                ?= ["\.min\."]

    # need to set some requirejs stuf
    if config.optimize and config.min
      logger.info "Optimize and minify both selected, setting r.js optimize property to 'none'"
      requirejs.optimize.overrides.optimize = "none"

    growl = newConfig.growl =       config.growl                ?= {}
    growl.onStartup =               config.growl.onStartup            ?= false
    growl.onSuccess =               config.growl.onSuccess            ?= {}
    growl.onSuccess.javascript =    config.growl.onSuccess.javascript ?= true
    growl.onSuccess.css =           config.growl.onSuccess.css        ?= true
    growl.onSuccess.template =      config.growl.onSuccess.template   ?= true
    growl.onSuccess.copy =          config.growl.onSuccess.copy       ?= true

    lint = newConfig.lint =    config.lint                     ?= {}
    lint.compiled =            config.lint.compiled            ?= {}
    lint.compiled.coffee =     config.lint.compiled.coffee     ?= true
    lint.compiled.javascript = config.lint.compiled.javascript ?= true
    lint.compiled.css =        config.lint.compiled.css        ?= true

    lint.copied =              config.lint.copied              ?= {}
    lint.copied.javascript =   config.lint.copied.javascript   ?= true
    lint.copied.css =          config.lint.copied.css          ?= true

    lint.vendor =              config.lint.vendor              ?= {}
    lint.vendor.javascript =   config.lint.vendor.javascript   ?= false
    lint.vendor.css =          config.lint.vendor.css          ?= false

    lint.rules =               config.lint.rules               ?= {}
    lint.rules.coffee =        config.lint.rules.coffee        ?= {}
    lint.rules.javascript =    config.lint.rules.javascript    ?= {}
    lint.rules.css =           config.lint.rules.css           ?= {}

    logger.debug "Full mimosa config:\n#{JSON.stringify(newConfig, null, 2)}"

    newConfig

  _validateSettings: (config) ->
    @_testPathExists(config.watch.sourceDir, "watch.sourceDir", true)
    unless config.virgin
      if !fs.existsSync(config.watch.compiledDir) and !config.isForceClean
        logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
        wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777

      @_testPathExists(config.server.path, "server.path", false) if config.isServer and not config.server.useDefaultServer

    # TODO, compilers: overrides paths

    jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir)
    @_testPathExists(jsDir,"watch.javascriptDir", true) unless config.virgin

  _testPathExists: (filePath, name, isDirectory) ->
    unless fs.existsSync filePath
      logger.fatal "#{name} (#{filePath}) cannot be found"
      return @fatalErrors++

    stats = fs.statSync filePath
    if (isDirectory and stats.isFile())
      logger.fatal "#{name} (#{filePath}) cannot be found, expecting a directory and is a file"
      return @fatalErrors++

    if (!isDirectory and stats.isDirectory())
      logger.fatal "#{name} (#{filePath}) cannot be found, expecting a file and is a directory"
      return @fatalErrors++

module.exports = {
  applyAndValidateDefaults: (new MimosaDefaults()).applyAndValidateDefaults
}