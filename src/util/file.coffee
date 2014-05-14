path = require 'path'
fs = require 'fs'
logger = require 'logmimosa'

exports.removeDotMimosa = ->
  dotMimosaDir = path.join(process.cwd(), ".mimosa")
  if fs.existsSync(dotMimosaDir)
    wrench = require 'wrench'
    wrench.rmdirSyncRecursive(dotMimosaDir)

exports.isCSS = isCSS = (fileName) ->
  path.extname(fileName) is ".css"

exports.isJavascript = isJavascript = (fileName) ->
  path.extname(fileName) is ".js"

exports.isVendorCSS = isVendorCSS = (config, fileName) ->
  fileName.indexOf(config.vendor.stylesheets) is 0

exports.isVendorJS = isVendorJS = (config, fileName) ->
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

exports.writeFile = (fileName, content, callback) ->
  dirname = path.dirname(fileName)
  mkdirRecursive dirname unless fs.existsSync dirname
  fs.writeFile fileName, content, "utf8", (err) ->
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

exports.setFileFlags = (config, options) ->
  exts = config.extensions
  ext = options.extension

  options.isJavascript = false
  options.isCSS = false
  options.isVendor = false
  options.isJSNotVendor = false
  options.isCopy = false

  if exts.template.indexOf(ext) > -1
    options.isTemplate = true
    options.isJavascript = true
    options.isJSNotVendor = true

  if exts.copy.indexOf(ext) > -1
    options.isCopy = true

  if exts.javascript.indexOf(ext) > -1 or (options.inputFile and isJavascript(options.inputFile))
    options.isJavascript = true
    if options.inputFile
      options.isVendor = isVendorJS(config, options.inputFile)
      options.isJSNotVendor = not options.isVendor

  if exts.css.indexOf(ext) > -1 or (options.inputFile and isCSS(options.inputFile))
    options.isCSS = true
    if options.inputFile
      options.isVendor = isVendorCSS(config, options.inputFile)