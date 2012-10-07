path = require 'path'
fs = require 'fs'

globWin = require('glob-whatev').glob
globRest = require('glob').sync

class FileUtils

  isCSS: (fileName) ->
    path.extname(fileName) is ".css"

  isJavascript: (fileName) ->
    path.extname(fileName) is ".js"

  isVendor: (fileName) ->
    fileName.split(path.sep).indexOf('vendor') > -1

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

  writeFile: (fileName, content, callback) =>
    dirname = path.dirname(fileName)
    @mkdirRecursive dirname unless fs.existsSync dirname
    fs.writeFile fileName, content, "ascii", (err) =>
      error = if err? then "Failed to write file: #{fileName}, #{err}"
      callback(error)

  isFirstFileNewer: (file1, file2, cb) ->
    fs.exists file2, (exists) ->
      return cb(true) if !exists
      fs.stat file2, (err, stats2) ->
        fs.stat file1, (err, stats1) ->
          if stats1.mtime > stats2.mtime then cb(true) else cb(false)

  # node-glob doesn't work entirely on win32
  # node-glob-whatev works on windows, but is terribly inefficient
  # for now, just switching between the two
  # Down the road get to a single lib
  # by 1) building own 2) fixing one of those or 3) finding one that works
  glob: (str, opts = {}) ->
    if process.platform is 'win32'
      globWin str, opts
    else
      globRest str

module.exports = new FileUtils
