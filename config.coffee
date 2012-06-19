# defaults commented out below

exports.config = {
  # watch:
    # originationDir: "assets"                       # base location of web assets
    # destinationDir: "public"                       # base location of compiled web assets
    # ignored: [".sass-cache"]                       # file extensions to not watch on file system

  # compilers:
    # javascript:
      # compileWith:"coffee"                         # Other options: "iced"
      # extensions:["coffee"]                        # list of extensions to compile
      # notifyOnSuccess: true                        # send growl notification on successful compilation
                                                     # will always send on failure

    # template:
      # compileWith:"handlebars"                     # Other options: "dust"
      # extensions: ["hbs", "handlebars"]            # list of extensions to compile
      # outputFileName: "javascripts/templates"      # the file all templates are compiled into
      # defineLocation: "vendor/handlebars"          # location inside destinationDir javascripts
                                                     # directory of browser library
      # helperFile:"javascripts/handlebars-helper"   # relevant to handlebars only, the path from originationDir
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
    # extensions: ["js","css","png","jpg","jpeg","gif"]  # the extensions of files to simply copy from originationDir
                                                         # to destinationDir.  vendor js/css, images, etc.
    # notifyOnSuccess:false                              # send growl notification on successful copy?

  # server:                               # configuration for server when server option is enabled via CLI
    # useDefaultServer : false            # whether or not mimosa starts a default server for you,
                                          # when true, mimosa starts its own on the port below
                                          # when false, mimosa will use server provided by path below
    # path: 'server.coffee'               # valid when useDefaultServer: false, path to file for provided server
                                          # which must contain a start() method
    # port: 4321                          # valid when useDefaultServer: true, port the default server will start on
    # base: '/app'                        # valid when useDefaultServer: true, base of the app in default mode
}