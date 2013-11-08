moduleManager = require '../modules'

_configTop = ->
  """
  # All of the below are mimosa defaults and only need to be uncommented in the event you want
  # to override them.
  #
  # IMPORTANT: Be sure to comment out all of the nodes from the base to the option you want to
  # override. If you want to turn change the source directory you would need to uncomment watch
  # and sourceDir. Also be sure to respect coffeescript indentation rules.  2 spaces per level
  # please!

  exports.config = {

    # minMimosaVersion:null   # The minimum Mimosa version that must be installed to use the
                              # project. Defaults to null, which means Mimosa will not check
                              # the version.  This is a no-nonsense way for big teams to ensure
                              # everyone stays up to date with the blessed Mimosa version for a
                              # project.

    ###
    The list of Mimosa modules to use for this application. The defaults (jshint, csslint, server,
    require, minify, live-reload, bower) come bundled with Mimosa and do not need to be installed.
    The 'mimosa-' that preceeds all Mimosa module names is assumed, however you can use it if you
    want. If a module is listed here that Mimosa is unaware of, Mimosa will attempt to install it.
    ###
    # modules: ['jshint', 'csslint', 'server', 'require', 'minify', 'live-reload', 'bower']

    # watch:
      # sourceDir: "assets"                # directory location of web assets, can be relative to
                                           # the project root, or absolute
      # compiledDir: "public"              # directory location of compiled web assets, can be
                                           # relative to the project root, or absolute
      # javascriptDir: "javascripts"       # Location of precompiled javascript (i.e.
                                           # coffeescript), must be relative to sourceDir
      # exclude: [/[/\\\\](\\.|~)[^/\\\\]+$/]   # regexes or strings matching the files to be
                                           # ignored by mimosa, the default matches all sorts of
                                           # dot files and temp files. Strings are paths and can
                                           # be relative to sourceDir or absolute.
      # throttle: 0                        # number of file adds the watcher handles before
                                           # taking a 100 millisecond pause to let those files
                                           # finish their processing. This helps avoid EMFILE
                                           # issues for projects containing large numbers of
                                           # files that all get copied at once. If the throttle
                                           # is set to 0, no throttling is performed. Recommended
                                           # to leave this set at 0, thedefault, until you start
                                           # encountering EMFILE problems. throttle has no effect
                                           # if usePolling is set to false.
      # usePolling: true                   # WARNING: Do not change this default if you are on
                                           # *Nix. Windows users, read on.
                                           # Whether or not to poll for system file changes.
                                           # Unless you have a lot files and your CPU starts
                                           # running hot, it is best to leave this setting alone.
      # interval: 100                      # Interval of file system polling.
      # binaryInterval: 300                # Interval of file system polling for binary files

    # vendor:                              # settings for vendor assets
      # javascripts: "javascripts/vendor"  # location, relative to the watch.sourceDir, of vendor
                                           # javascript assets. Unix style slashes please.
      # stylesheets: "stylesheets/vendor"  # location, relative to the watch.sourceDir, of vendor
                                           # stylesheet assets. Unix style slashes please.

  """

_configBottom = -> "\n}"

buildConfigText = ->
  modules = moduleManager.all
  configText = _configTop()
  for mod in modules
    if mod.placeholder?
      ph = mod.placeholder()
      configText += ph if ph?
  configText += _configBottom()

  if moduleManager.configModuleString?
    configText = configText.replace("  # modules: ['jshint', 'csslint', server', 'require', 'minify', 'live-reload', 'bower']", "  modules: " + moduleManager.configModuleString)

  configText

module.exports = buildConfigText