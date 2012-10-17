# order is important if something needs to effect the config before moving onto the next
# i.e. compilers adding various extensions to config.extensions

compilers = require './compilers'
file =      require './file'
linters =   require 'mimosa-lint'
minify =    require 'mimosa-minify'
req =       require 'mimosa-require'
server =    require 'mimosa-server'
logger =    require 'mimosa-logger'

module.exports =
  all:   [file, compilers, linters, minify, req, server, logger]
  basic: [file, compilers]