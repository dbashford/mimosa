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
    # sourceDir: "assets"                       # directory location of web assets
    # compiledDir: "public"                       # directory location of compiled web assets
    # ignored: [".sass-cache"]                       # file extensions to not watch on file system

  # compilers:
    # javascript:
      # compileWith:"coffee"                         # Other options: "iced"
      # extensions:["coffee"]                        # list of extensions to compile
      # notifyOnSuccess: true                        # send growl notification on successful compilation
                                                     # will always send on failure
      # metalint: true                               # will run coffeelint over coffee/iced files when they are saved
                                                     # using the 'coffeelint' below.  Lint errors will not generate growl messages
                                                     # or stop compiilation, but will be written to the Mimosa console
      # lint: true                                   # will run jshint over compiled javascript files.  lint errors will not generate
                                                     # growl messages or stop compilation, but will be written to the Mimosa console
                                                     # not yet exposing jshint options as Mimosa options.  If anyone wants it...

    # template:
      # compileWith:"handlebars"                     # Other options: "dust"
      # extensions: ["hbs", "handlebars"]            # list of extensions to compile
      # outputFileName: "javascripts/templates"      # the file all templates are compiled into
      # defineLocation: "vendor/handlebars"          # location inside compiledDir javascripts
                                                     # directory of browser library
      # helperFile:"javascripts/handlebars-helpers"  # relevant to handlebars only, the path from sourceDir
                                                     # to the file containing handlebars helper functions, does
                                                     # not need to exist
      # notifyOnSuccess: true                        # send growl notification on successful compilation?
                                                     # will always send on failure

    # css:
      # compileWith:"sass"                           # Other options: none just yet
      # extensions:["scss", "sass"]                  # list of extensions to compile
      # hasCompass: true                             # relevant to sass only, is compass included?
      # notifyOnSuccess: true                        # send growl notification on successful compilation?
                                                     # will always send on failure

  # copy:
    # extensions: ["js","css","png","jpg","jpeg","gif"]  # the extensions of files to simply copy from sourceDir
                                                         # to compiledDir.  vendor js/css, images, etc.
    # notifyOnSuccess:false                              # send growl notification on successful copy?

  # server:                               # configuration for server when server option is enabled via CLI
    # useDefaultServer: false             # whether or not mimosa starts a default server for you,
                                          # when true, mimosa starts its own on the port below
                                          # when false, mimosa will use server provided by path below
    # useReload: true                     # valid for both default and custom server, when true, browser will be
                                          # reloaded when asset is compiled.  This adds a few javascript files to
                                          # the dev version of the app
    # path: 'server.coffee'               # valid when useDefaultServer: false, path to file for provided server
                                          # which must contain a start() method
    # port: 4321                          # valid when useDefaultServer: true, port the default server will start on
    # base: '/app'                        # valid when useDefaultServer: true, base of the app in default mode


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