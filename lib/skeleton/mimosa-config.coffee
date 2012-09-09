# Mimosa Config
#
# All of the below are mimosa defaults and only need to be uncommented
# in the event you want to override them.
#
# IMPORTANT: Be sure to comment out all of the nodes from the base to the
# option you want to override.  If you want to turn javascript linting off
# you would need to uncomment 1) lint, 2) compiled, and 3) javascript.  Also be sure
# to respect coffeescript indentation rules.  2 spaces per level please! =)

exports.config = {

  # watch:
    # sourceDir: "assets"                 # directory location of web assets
    # compiledDir: "public"               # directory location of compiled web assets
    # ignored: [".sass-cache"]            # files to not watch on file system, any file containing one of the strings listed here
                                          # will be skipped
    # throttle: 0                         # number of file adds the watcher handles before taking a 100 millisecond pause to let
                                          # those files finish their processing. This helps avoid EMFILE issues for projects
                                          # containing large numbers of files that all get copied at once. If the throttle is
                                          # set to 0, no throttling is performed. Recommended to leave this set at 0, the
                                          # default, until you start encountering EMFILE problems.

  # compilers:
    # javascript:
      # directory: "javascripts"              # Location of precompiled javascript (coffeescript for instance), and therefore
                                              # also the location of the compiled javascript.
                                              # For now this is only used by requirejs optimization, the rest of Mimosa doesn't
                                              # care where you put your javascript (as long as it is inside the sourceDir)
      # compileWith: "coffee"                 # Other options: "iced", "none".  "none" assumes you are coding js by hand and
                                              # the copy config will move that over for you
      # extensions: ["coffee"]                # list of extensions to compile

    # template:
      # compileWith: "handlebars"                                    # Other ops:"dust","jade","hogan","underscore","lodash","html","none".
                                                                     # "none" assumes you aren't using any micro-templating solution.
      # extensions: ["hbs", "handlebars"]                            # list of extensions to compile
      # outputFileName: "javascripts/templates"                      # the file all templates are compiled into
      # helperFiles:["javascripts/app/template/handlebars-helpers"]  # relevant to handlebars only, the paths from sourceDir to the files
                                                                     # containing handlebars helper/partial registrations, does not need
                                                                     # to exist

    # css:
      # compileWith: "stylus"              # Other options: "none", "less", "sass".  "none" assumes you are coding pure CSS and
                                           # the copy config will move that over for you.
      # extensions: ["styl"]               # list of extensions to compile

  ###
  # the extensions of files to simply copy from sourceDir to compiledDir.  vendor js/css, images, etc.
  ###
  # copy:
    # extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]

  # server:                               # configuration for server when server option is enabled via CLI
    # useDefaultServer: false             # whether or not mimosa starts a default server for you, when true, mimosa starts its
                                          # own on the port below, when false, mimosa will use server provided by path below
    # useReload: true                     # valid for both default and custom server, when true, browser will be reloaded when
                                          # asset is compiled.  This adds a few javascript files to the layout of the dev
                                          # version of the app
    # path: 'server.coffee'               # valid when useDefaultServer: false, path to file for provided server which must contain
                                          # export startServer method that takes an enriched mimosa-config object
    # port: 3000                          # port to start server on
    # base: ''                            # base of the app in default mode
    # views:                              # configuration for the view layer of your application
      # compileWith: 'jade'               # Other valid options: "hogan", "html". The compiler for your views.
      # extension: 'jade'                 # extension of your server views
      # path: 'views'                     # path from the root of your project to your views

  # require:                              # configuration for requirejs options.
    # verify:                             # settings for requirejs path verification
      # enabled: true                     # Whether or not to perform verification
    # optimize :
      # inferConfig:true                  # Mimosa figures out all you'd need for a simple r.js optimizer run. If you rather Mimosa
                                          # not do that, set inferConfig to false and provide your config in the overrides section.
                                          # See here https://github.com/dbashford/mimosa#requirejs-optimizer-defaults to see what
                                          # the defaults are.
      # overrides:                        # Optimization configuration and Mimosa overrides. If you need to make tweaks uncomment
                                          # this line and add the r.js config (http://requirejs.org/docs/optimization.html#options)
                                          # as newparamters inside the overrides ojbect. To unset Mimosa's defaults, set a property
                                          # to null

  # minify:                               # Configuration for non-require minification/compression via uglify using the --minify flag.
    # exclude:["\.min\."]                 # List of regexes to exclude files when running minification.  Any path with ".min." in its
                                          # name, like jquery.min.js, is assumed to already be minified and is ignored by default.
                                          # Override this property if you have other files that you'd like to exempt from minification

  # growl:
    # onStartup: false                    # Controls whether or not to Growl when assets successfully compile/copy on startup,
                                          # If you've got 100 CoffeeScript files, and you do a clean and then start watching,
                                          # you'll get 100 Growl notifications.  This is set to false be default to prevent that.
    # onSuccess:                          # Controls whether or not to Growl when assets successfully compile/copy
      # javascript: true                  # send growl notification on successful compilation? will always send on failure
      # css: true                         # send growl notification on successful compilation? will always send on failure
      # template: true                    # send growl notification on successful compilation? will always send on failure
      # copy: true                        # send growl notification on successful copy?

  # lint:                                 # settings for js, css linting/hinting
    # compiled:                           # settings for compiled files
      # javascript:true                   # fire jshint on successful compile of meta-language to javascript
      # css:true                          # fire csslint on successful compile of meta-language to css
    # copied:                             # settings for copied files, files already in .css and .js files
      # javascript: true                  # fire jshint for copied javascript files
      # css: true                         # fire csslint for copied css files
    # vendor:                             # settings for vendor files
      # javascript: false                 # fire jshint for copied vendor javascript files (like jquery)
      # css: false                        # fire csslint for copied vendor css files (like bootstrap)
    # rules:                              # All hints/lints come with defaults built in.  Here is where you'd override those defaults.
                                          # Below is listed an example of an overridden default for each lint type, also listed, next
                                          # to the lint types is the url to find the settings for overriding.
      # javascript:                       # Settings: http://www.jshint.com/options/
        # plusplus: true                  # This is an example override, this is not a default
      # css:                              # Settings: https://github.com/stubbornella/csslint/wiki/Rules
        # floats: false                   # This is an example override, this is not a default

}