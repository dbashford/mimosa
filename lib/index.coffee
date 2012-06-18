require 'sugar'
color  = require("ansi-color").set
logger = require './util/logger'

class Mimosa

  watch: (config, root) ->
    compilers = [new (require("./compilers/copy"))(config.copy)]
    for category, catConfig of config.compilers
      try
        compiler = require("./compilers/#{category}/#{catConfig.compileWith}")
        compilers.push(new compiler(catConfig))
        logger.info "Adding compiler: #{category}/#{catConfig.compileWith}"
      catch err
        logger.info "Unable to find matching compiler for #{category}/#{catConfig.compileWith}"

    watcher = require('./watch/watcher')(config.watch, root)
    watcher.registerCompilers(compilers)

module.exports = new Mimosa
