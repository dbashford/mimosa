path = require 'path'
fs = require 'fs'

logger = require 'logmimosa'

exports.isCSS = (fileName) ->
  path.extname(fileName) is ".css"

exports.isJavascript = (fileName) ->
  path.extname(fileName) is ".js"

exports.isVendorCSS = (config, fileName) ->
  fileName.indexOf(config.vendor.stylesheets) is 0

exports.isVendorJS = (config, fileName) ->
  fileName.indexOf(config.vendor.javascripts) is 0

exports.mkdirRecursive = mkdirRecursive = (p, made) ->
  if !made then made = null
  p = path.resolve(p)

  try
    fs.mkdirSync p
    made = made || p
  catch err
    if err.code is 'ENOENT'
      made = mkdirRecursive path.dirname(p), made
      mkdirRecursive p, made
    else if err.code is 'EEXIST'
      try
        stat = fs.statSync(p);
      catch err2
        throw err
      if !stat.isDirectory() then throw err
    else throw err
  made

exports.writeFile = (fileName, content, callback) =>
  dirname = path.dirname(fileName)
  mkdirRecursive dirname unless fs.existsSync dirname
  fs.writeFile fileName, content, "utf8", (err) =>
    error = if err? then "Failed to write file: #{fileName}, #{err}"
    callback(error)

exports.isFirstFileNewer = (file1, file2, cb) ->
  return cb(false) unless file1?
  return cb(true) unless file2?

  fs.exists file1, (exists1) ->
    unless exists1
      logger.warn "Detected change with file [[ #{file1} ]] but is no longer present."
      return cb(false)

    fs.exists file2, (exists2) ->
      unless exists2
        logger.debug "File missing, so is new file [[ #{file2} ]]"
        return cb(true)

      fs.stat file2, (err, stats2) ->
        fs.stat file1, (err, stats1) ->
          unless stats1? and stats2?
            logger.debug "Somehow a file went missing [[ #{stats1} ]], [[ #{stats2} ]] "
            return cb(false)

          if stats1.mtime > stats2.mtime then cb(true) else cb(false)

exports.readdirSyncRecursive = (baseDir, excludes = [], excludeRegex, ignoreDirectories = false) ->
  baseDir = baseDir.replace /\/$/, ''

  readdirSyncRecursive = (baseDir) ->
    curFiles = fs.readdirSync(baseDir).map (f) ->
      path.join(baseDir, f)

    if excludes.length > 0
      curFiles = curFiles.filter (f) ->
        for exclude in excludes
          if f is exclude or f.indexOf(exclude) is 0
            return false
        true

    if excludeRegex
      curFiles = curFiles.filter (f) -> not f.match(excludeRegex)

    nextDirs = curFiles.filter (fname) ->
      fs.statSync(fname).isDirectory()

    if ignoreDirectories
      curFiles = curFiles.filter (fname) ->
        fs.statSync(fname).isFile()

    files = curFiles
    while (nextDirs.length)
      files = files.concat(readdirSyncRecursive(nextDirs.shift()))
    files

  readdirSyncRecursive(baseDir)