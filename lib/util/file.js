var fs, isCSS, isJavascript, isVendorCSS, isVendorJS, logger, mkdirRecursive, path;

path = require('path');

fs = require('fs');

logger = require('logmimosa');

exports.removeDotMimosa = function() {
  var dotMimosaDir, wrench;
  dotMimosaDir = path.join(process.cwd(), ".mimosa");
  if (fs.existsSync(dotMimosaDir)) {
    wrench = require('wrench');
    return wrench.rmdirSyncRecursive(dotMimosaDir);
  }
};

exports.isCSS = isCSS = function(fileName) {
  return path.extname(fileName) === ".css";
};

exports.isJavascript = isJavascript = function(fileName) {
  return path.extname(fileName) === ".js";
};

exports.isVendorCSS = isVendorCSS = function(config, fileName) {
  return fileName.indexOf(config.vendor.stylesheets) === 0;
};

exports.isVendorJS = isVendorJS = function(config, fileName) {
  return fileName.indexOf(config.vendor.javascripts) === 0;
};

exports.mkdirRecursive = mkdirRecursive = function(p, made) {
  var err, err2, stat;
  if (!made) {
    made = null;
  }
  p = path.resolve(p);
  try {
    fs.mkdirSync(p);
    made = made || p;
  } catch (_error) {
    err = _error;
    if (err.code === 'ENOENT') {
      made = mkdirRecursive(path.dirname(p), made);
      mkdirRecursive(p, made);
    } else if (err.code === 'EEXIST') {
      try {
        stat = fs.statSync(p);
      } catch (_error) {
        err2 = _error;
        throw err;
      }
      if (!stat.isDirectory()) {
        throw err;
      }
    } else {
      throw err;
    }
  }
  return made;
};

exports.writeFile = function(fileName, content, callback) {
  var dirname;
  dirname = path.dirname(fileName);
  if (!fs.existsSync(dirname)) {
    mkdirRecursive(dirname);
  }
  return fs.writeFile(fileName, content, "utf8", function(err) {
    var error;
    error = err != null ? "Failed to write file: " + fileName + ", " + err : void 0;
    return callback(error);
  });
};

exports.isFirstFileNewer = function(file1, file2, cb) {
  if (file1 == null) {
    return cb(false);
  }
  if (file2 == null) {
    return cb(true);
  }
  return fs.exists(file1, function(exists1) {
    if (!exists1) {
      logger.warn("Detected change with file [[ " + file1 + " ]] but is no longer present.");
      return cb(false);
    }
    return fs.exists(file2, function(exists2) {
      if (!exists2) {
        logger.debug("File missing, so is new file [[ " + file2 + " ]]");
        return cb(true);
      }
      return fs.stat(file2, function(err, stats2) {
        return fs.stat(file1, function(err, stats1) {
          if (!((stats1 != null) && (stats2 != null))) {
            logger.debug("Somehow a file went missing [[ " + stats1 + " ]], [[ " + stats2 + " ]] ");
            return cb(false);
          }
          if (stats1.mtime > stats2.mtime) {
            return cb(true);
          } else {
            return cb(false);
          }
        });
      });
    });
  });
};

exports.readdirSyncRecursive = function(baseDir, excludes, excludeRegex, ignoreDirectories) {
  var readdirSyncRecursive;
  if (excludes == null) {
    excludes = [];
  }
  if (ignoreDirectories == null) {
    ignoreDirectories = false;
  }
  baseDir = baseDir.replace(/\/$/, '');
  readdirSyncRecursive = function(baseDir) {
    var curFiles, files, nextDirs;
    curFiles = fs.readdirSync(baseDir).map(function(f) {
      return path.join(baseDir, f);
    });
    if (excludes.length > 0) {
      curFiles = curFiles.filter(function(f) {
        var exclude, _i, _len;
        for (_i = 0, _len = excludes.length; _i < _len; _i++) {
          exclude = excludes[_i];
          if (f === exclude || f.indexOf(exclude) === 0) {
            return false;
          }
        }
        return true;
      });
    }
    if (excludeRegex) {
      curFiles = curFiles.filter(function(f) {
        return !f.match(excludeRegex);
      });
    }
    nextDirs = curFiles.filter(function(fname) {
      return fs.statSync(fname).isDirectory();
    });
    if (ignoreDirectories) {
      curFiles = curFiles.filter(function(fname) {
        return fs.statSync(fname).isFile();
      });
    }
    files = curFiles;
    while (nextDirs.length) {
      files = files.concat(readdirSyncRecursive(nextDirs.shift()));
    }
    return files;
  };
  return readdirSyncRecursive(baseDir);
};

exports.setFileFlags = function(config, options) {
  var ext, exts;
  exts = config.extensions;
  ext = options.extension;
  options.isJavascript = false;
  options.isCSS = false;
  options.isVendor = false;
  options.isJSNotVendor = false;
  options.isCopy = false;
  if (exts.template.indexOf(ext) > -1) {
    options.isTemplate = true;
    options.isJavascript = true;
    options.isJSNotVendor = true;
  }
  if (exts.copy.indexOf(ext) > -1) {
    options.isCopy = true;
  }
  if (exts.javascript.indexOf(ext) > -1 || (options.inputFile && isJavascript(options.inputFile))) {
    options.isJavascript = true;
    if (options.inputFile) {
      options.isVendor = isVendorJS(config, options.inputFile);
      options.isJSNotVendor = !options.isVendor;
    }
  }
  if (exts.css.indexOf(ext) > -1 || (options.inputFile && isCSS(options.inputFile))) {
    options.isCSS = true;
    if (options.inputFile) {
      return options.isVendor = isVendorCSS(config, options.inputFile);
    }
  }
};
