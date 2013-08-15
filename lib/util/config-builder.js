var buildConfigText, moduleManager, _configBottom, _configTop;

moduleManager = require('../modules');

_configTop = function() {
  return "# All of the below are mimosa defaults and only need to be uncommented in the event you want\n# to override them.\n#\n# IMPORTANT: Be sure to comment out all of the nodes from the base to the option you want to\n# override. If you want to turn change the source directory you would need to uncomment watch\n# and sourceDir. Also be sure to respect coffeescript indentation rules.  2 spaces per level\n# please!\n\nexports.config = {\n\n  # minMimosaVersion:null   # The minimum Mimosa version that must be installed to use the\n                            # project. Defaults to null, which means Mimosa will not check\n                            # the version.  This is a no-nonsense way for big teams to ensure\n                            # everyone stays up to date with the blessed Mimosa version for a\n                            # project.\n\n  ###\n  The list of Mimosa modules to use for this application. The defaults (lint, server, require,\n  minify, live-reload, bower) come bundled with Mimosa and do not need to be installed. The\n  'mimosa-' that preceeds all Mimosa module names is assumed, however you can use it if you\n  want. If a module is listed here that Mimosa is unaware of, Mimosa will attempt to install it.\n  ###\n  # modules: ['lint', 'server', 'require', 'minify', 'live-reload', 'bower']\n\n  # watch:\n    # sourceDir: \"assets\"                # directory location of web assets, can be relative to\n                                         # the project root, or absolute\n    # compiledDir: \"public\"              # directory location of compiled web assets, can be\n                                         # relative to the project root, or absolute\n    # javascriptDir: \"javascripts\"       # Location of precompiled javascript (i.e.\n                                         # coffeescript), must be relative to sourceDir\n    # exclude: [/[/\\\\](\\.|~)[^/\\\\]+$/]   # regexes or strings matching the files to be\n                                         # ignored by mimosa, the default matches all sorts of\n                                         # dot files and temp files. Strings are paths and can\n                                         # be relative to sourceDir or absolute.\n    # throttle: 0                        # number of file adds the watcher handles before\n                                         # taking a 100 millisecond pause to let those files\n                                         # finish their processing. This helps avoid EMFILE\n                                         # issues for projects containing large numbers of\n                                         # files that all get copied at once. If the throttle\n                                         # is set to 0, no throttling is performed. Recommended\n                                         # to leave this set at 0, thedefault, until you start\n                                         # encountering EMFILE problems. throttle has no effect\n                                         # if usePolling is set to false.\n    # usePolling: true                   # WARNING: Do not change this default if you are on\n                                         # *Nix. Windows users, read on.\n                                         # Whether or not to poll for system file changes.\n                                         # Unless you have a lot files and your CPU starts\n                                         # running hot, it is best to leave this setting alone.\n    # interval: 100                      # Interval of file system polling.\n    # binaryInterval: 300                # Interval of file system polling for binary files\n\n  # vendor:                              # settings for vendor assets\n    # javascripts: \"javascripts/vendor\"  # location, relative to the watch.sourceDir, of vendor\n                                         # javascript assets. Unix style slashes please.\n    # stylesheets: \"stylesheets/vendor\"  # location, relative to the watch.sourceDir, of vendor\n                                         # stylesheet assets. Unix style slashes please.\n";
};

_configBottom = function() {
  return "\n}";
};

buildConfigText = function() {
  var configText, mod, modules, ph, _i, _len;
  modules = moduleManager.all;
  configText = _configTop();
  for (_i = 0, _len = modules.length; _i < _len; _i++) {
    mod = modules[_i];
    if (mod.placeholder != null) {
      ph = mod.placeholder();
      if (ph != null) {
        configText += ph;
      }
    }
  }
  configText += _configBottom();
  if (moduleManager.configModuleString != null) {
    configText = configText.replace("  # modules: ['lint', 'server', 'require', 'minify', 'live-reload', 'bower']", "  modules: " + moduleManager.configModuleString);
  }
  return configText;
};

module.exports = buildConfigText;
