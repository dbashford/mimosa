# Mimosa Config
#
# All of the below are mimosa defaults and only need to be uncommented
# in the event you want to override them.
#
# IMPORTANT: Be sure to comment out all of the nodes from the base to the
# option you want to override.  If you want to turn javascript linting off
# you would need to uncomment 1) compilers, 2) javascript, and 3) lint.  Also be sure
# to respect coffeescript indentation rules.  2 spaces per level please! =)

exports.config = {

  # watch:

    # sourceDir: "assets"                            # directory location of web assets
    # compiledDir: "public"                          # directory location of compiled web assets
    # ignored: [".sass-cache"]                       # file extensions to not watch on file system

  # compilers:
    # javascript:
      # directory: "javascripts"                     # Location of precompiled javascript (coffeescript for instance), and therefore
                                                     # also the location of the compiled javascript.
                                                     # For now this is only used by requirejs optimization, the rest of Mimosa doesn't
                                                     # care where you put your javascript (as long as it is inside the sourceDir)
      # compileWith: "coffee"                        # Other options: "iced", "none".  "none" assumes you are coding js by hand and
                                                     # the copy config will move that over for you
      # extensions: ["coffee"]                       # list of extensions to compile
      # notifyOnSuccess: true                        # send growl notification on successful compilation
                                                     # will always send on failure
      # metalint: true                               # will run coffeelint over coffee/iced files when they are saved
                                                     # using the 'coffeelint' below.  Lint errors will not generate growl messages
                                                     # or stop compiilation, but will be written to the Mimosa console
      # lint: true                                   # will run jshint over compiled javascript files.  lint errors will not generate
                                                     # growl messages or stop compilation, but will be written to the Mimosa console
                                                     # not yet exposing jshint options as Mimosa options.  If anyone wants it...

    # template:
      # compileWith: "handlebars"                                    # Other options: "dust", "jade", "none". "none" assumes you aren't
                                                                     # using any micro-templating solution.
      # extensions: ["hbs", "handlebars"]                            # list of extensions to compile
      # outputFileName: "javascripts/templates"                      # the file all templates are compiled into
      # helperFiles:["javascripts/app/template/handlebars-helpers"]  # relevant to handlebars only, the paths from sourceDir to the files
                                                                     # containing handlebars helper/partial registrations, does not need
                                                                     # to exist
      # notifyOnSuccess: true                                        # send growl notification on successful compilation?
                                                                     # will always send on failure

    # css:
      # compileWith: "sass"                          # Other options: "none".  "none" assumes you are coding pure CSS and
                                                     # the copy config will move that over for you.  More compilers to come.
      # extensions: ["scss", "sass"]                 # list of extensions to compile
      # notifyOnSuccess: true                        # send growl notification on successful compilation?
                                                     # will always send on failure
      # lint:
        # enabled: true                              # determines whether or not csslint will fire on compiled css csslint rule config
        # rules:                                     # List of CSSLint rules: https://github.com/stubbornella/csslint/wiki/Rules
                                                     # If you do not want that rule enabled by mimosa, uncomment {lint.rules} and add below it
                                                     # the name of the rule and 'false'.  An example is provided below for this rule:
                                                     # https://github.com/stubbornella/csslint/wiki/Disallow-too-many-floats
          # floats: false                            # This is NOT a default, merely an example of how to turn a rule off

  # copy:
    # extensions: ["js","css","png","jpg","jpeg","gif","html"]  # the extensions of files to simply copy from sourceDir
                                                                # to compiledDir.  vendor js/css, images, etc.
    # notifyOnSuccess:false                                     # send growl notification on successful copy?

  # server:                               # configuration for server when server option is enabled via CLI
    # useDefaultServer: false             # whether or not mimosa starts a default server for you,
                                          # when true, mimosa starts its own on the port below
                                          # when false, mimosa will use server provided by path below
    # useReload: true                     # valid for both default and custom server, when true, browser will be
                                          # reloaded when asset is compiled.  This adds a few javascript files to
                                          # the layout of the dev version of the app
    # path: 'server.coffee'               # valid when useDefaultServer: false, path to file for provided server
                                          # which must contain a start() method
    # port: 3000                          # valid when useDefaultServer: true, port the default server will start on
    # base: '/app'                        # valid when useDefaultServer: true, base of the app in default mode

  # require:                              # configuration for requirejs optimizer. You can uncomment and change the
                                          # configuration here, and you can also append any new or different
                                          # r.js configuration (http://requirejs.org/docs/optimization.html#options)
                                          # as new paramters inside this require option. for example any shims, additional modules.
                                          # The require 'baseUrl' is set by combining the compiledDir with the compilers.javascript.directory
    # optimizationEnabled: true           # Turn off production mode optimization.  When set to true, requirejs (r.js) optimizer will be
                                          # used to shrink all the javascript for the {require.name} modules down to single files per module.
                                          # When set to false, mimosa will behave identically in production as in dev
    # name: 'main'                        # names of the module, this matches the name of the Mimosa default require.js script tag
                                          # 'data-main' (see views/layout.jade), which then points to the require.js configuration
                                          # javascript file: main.js (see javascripts/main.coffee).
    # out: 'main-built.js'                # name of the compiled file.  This is placed at the root of the
                                          # {compiledDir}/{compilers.javascript.directory} directory.
    # paths:                              # paths to files aliased in your {require.name}.js file.
      # jquery: 'vendor/jquery'           # path to jquery which by default lives in the vendor folder

  # The following is coffeelint config. If compilers.javascript.lint is true, and coffee or iced is chosen as
  # the javascript compiler, these configuration options will apply.  Uncomment the coffeelint line and whichever
  # options you want to override.
  #
  # For information on coffeelint, and on individual options, see http://www.coffeelint.org/
  #
  # coffeelint:
  #   no_tabs:
  #     level: "error"
  #   no_trailing_whitespace:
  #     level: "error"
  #   max_line_length:
  #     value: 80,
  #     level: "error"
  #   camel_case_classes:
  #     level: "error"
  #   indentation:
  #     value: 2
  #     level: "error"
  #   no_implicit_braces:
  #     level: "ignore"
  #   no_trailing_semicolons:
  #     level: "error"
  #   no_plusplus:
  #     level: "ignore"
  #   no_throwing_strings:
  #     level: "error"
  #   cyclomatic_complexity:
  #     value: 11
  #     level: "ignore"
  #   line_endings:
  #     value: "unix"
  #     level: "ignore"
  #   no_implicit_parens:
  #     level: "ignore"
}