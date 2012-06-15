require 'sugar'
color = require("ansi-color").set

module.exports = class Mimosa

  watch: (config, root) ->
    compilers = [new (require("./compilers/copy"))(config.copy)]
    for category, catConfig of config.compilers
      try
        compiler = require("./compilers/#{category}/#{catConfig.compileWith}")
        compilers.push(new compiler(catConfig))
        console.log color("Adding compiler: #{category}/#{catConfig.compileWith}", "green+bold")
      catch err
        console.log color("Unable to find matching compiler for #{category}/#{catConfig.compileWith}", "red+bold")

    watcher = require('./watch/watcher')(config.watch, root)
    watcher.registerCompilers(compilers)

module.exports = new Mimosa
