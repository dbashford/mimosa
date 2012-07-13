path = require 'path'
fs = require 'fs'

class FileUtils

  mkdirRecursive: (p, made) ->
    if !made then made = null
    p = path.resolve(p)

    try
      fs.mkdirSync p
      made = made || p
    catch err
      if err.code is 'ENOENT'
        made = @mkdirRecursive path.dirname(p), made
        @mkdirRecursive p, made
      else if err.code is 'EEXIST'
        try
          stat = fs.statSync(p);
        catch err2
          throw err
        if !stat.isDirectory() then throw err
      else throw err
    made

module.exports = new FileUtils
