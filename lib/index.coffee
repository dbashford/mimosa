require 'sugar'

program = require 'commander'
version =  require('../package.json').version

class Mimosa

  constructor: ->
    program.version(version)

    require('./command/new')(program)
    require('./command/config')(program)
    require('./command/build')(program)
    require('./command/clean')(program)
    require('./command/watch')(program)

    program.parse process.argv

module.exports = new Mimosa