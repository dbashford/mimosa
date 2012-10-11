# order is important if something needs to effect the config before moving onto the next
# i.e. compilers adding various extensions to config.extensions

compilers = require './compilers'
file = require './file'
linters = require './lint'
minify = require './minify'
req = require './require'

module.exports =
  all:      [file, compilers, linters.js, linters.css, minify, req]
  builtIns: [file, compilers, linters.js, linters.css, minify, req]
  basic:    [file, compilers]