/* *****************************************************************************
Copyright (c) Microsoft Corporation. All rights reserved.
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at http://www.apache.org/licenses/LICENSE-2.0

THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
MERCHANTABLITY OR NON-INFRINGEMENT.

See the Apache Version 2.0 License for specific language governing permissions
and limitations under the License.
***************************************************************************** */

var _fs = require('fs');
var _path = require('path');
var _module = require('module');

module.exports = {
    readFile: function (file) {
        var buffer = _fs.readFileSync(file);
        switch(buffer[0]) {
            case 254: {
                if(buffer[1] == 255) {
                    var i = 0;
                    while((i + 1) < buffer.length) {
                        var temp = buffer[i];
                        buffer[i] = buffer[i + 1];
                        buffer[i + 1] = temp;
                        i += 2;
                    }
                    return buffer.toString("ucs2", 2);
                }
                break;

            }
            case 255: {
                if(buffer[1] == 254) {
                    return buffer.toString("ucs2", 2);
                }
                break;

            }
            case 239: {
                if(buffer[1] == 187) {
                    return buffer.toString("utf8", 3);
                }

            }
        }
        return buffer.toString();
    },
    writeFile: _fs.writeFileSync,
    deleteFile: function (path) {
        try  {
            _fs.unlinkSync(path);
        } catch (e) {
        }
    },
    fileExists: function (path) {
        return _fs.existsSync(path);
    },
    createFile: function (path) {
        function mkdirRecursiveSync(path) {
            var stats = _fs.statSync(path);
            if(stats.isFile()) {
                throw "\"" + path + "\" exists but isn't a directory.";
            } else {
                if(stats.isDirectory()) {
                    return;
                } else {
                    mkdirRecursiveSync(_path.dirname(path));
                    _fs.mkdirSync(path, 509);
                }
            }
        }
        mkdirRecursiveSync(_path.dirname(path));
        var fd = _fs.openSync(path, 'w');
        return {
            Write: function (str) {
                _fs.writeSync(fd, str);
            },
            WriteLine: function (str) {
                _fs.writeSync(fd, str + '\r\n');
            },
            Close: function () {
                _fs.closeSync(fd);
                fd = null;
            }
        };
    },
    dir: function dir(path, spec, options) {
        options = options || {
        };
        function filesInFolder(folder) {
            var paths = [];
            var files = _fs.readdirSync(folder);
            for(var i = 0; i < files.length; i++) {
                var stat = _fs.statSync(folder + "\\" + files[i]);
                if(options.recursive && stat.isDirectory()) {
                    paths = paths.concat(filesInFolder(folder + "\\" + files[i]));
                } else {
                    if(stat.isFile() && (!spec || files[i].match(spec))) {
                        paths.push(folder + "\\" + files[i]);
                    }
                }
            }
            return paths;
        }
        return filesInFolder(path);
    },
    createDirectory: function (path) {
        if(!this.directoryExists(path)) {
            _fs.mkdirSync(path);
        }
    },
    directoryExists: function (path) {
        return _fs.existsSync(path) && _fs.lstatSync(path).isDirectory();
    },
    resolvePath: function (path) {
        return _path.resolve(path);
    },
    dirName: function (path) {
        return _path.dirname(path);
    },
    findFile: function (rootPath, partialFilePath) {
        var path = rootPath + "/" + partialFilePath;
        while(true) {
            if(_fs.existsSync(path)) {
                try  {
                    var content = this.readFile(path);
                    return {
                        content: content,
                        path: path
                    };
                } catch (err) {
                }
            } else {
                var parentPath = _path.resolve(rootPath, "..");
                if(rootPath === parentPath) {
                    return null;
                } else {
                    rootPath = parentPath;
                    path = _path.resolve(rootPath, partialFilePath);
                }
            }
        }
    },
    print: function (str) {
        process.stdout.write(str);
    },
    printLine: function (str) {
        process.stdout.write(str + '\n');
    },
    arguments: process.argv.slice(2),
    stderr: {
        Write: function (str) {
            process.stderr.write(str);
        },
        WriteLine: function (str) {
            process.stderr.write(str + '\n');
        },
        Close: function () {
        }
    },
    watchFiles: function (files, callback) {
        var watchers = [];
        var firstRun = true;
        var isWindows = /^win/.test(process.platform);
        var processingChange = false;
        var fileChanged = function (e, fn) {
            if(!firstRun && !isWindows) {
                for(var i = 0; i < files.length; ++i) {
                    _fs.unwatchFile(files[i]);
                }
            }
            firstRun = false;
            if(!processingChange) {
                processingChange = true;
                callback();
                setTimeout(function () {
                    processingChange = false;
                }, 100);
            }
            if(isWindows && watchers.length === 0) {
                for(var i = 0; i < files.length; ++i) {
                    var watcher = _fs.watch(files[i], fileChanged);
                    watchers.push(watcher);
                    watcher.on('error', function (e) {
                        process.stderr.write("ERROR" + e);
                    });
                }
            } else {
                if(!isWindows) {
                    for(var i = 0; i < files.length; ++i) {
                        _fs.watchFile(files[i], {
                            interval: 500
                        }, fileChanged);
                    }
                }
            }
        };
        fileChanged();
        return true;
    },
    run: function (source, filename) {
        require.main.filename = filename;
        require.main.paths = _module._nodeModulePaths(_path.dirname(_fs.realpathSync(filename)));
        require.main._compile(source, filename);
    },
    getExecutingFilePath: function () {
        return process.mainModule.filename;
    },
    quit: process.exit
};
