# 0.0.28alpha - August ?? 2012
### Major Changes
* #50, integrated handlebars partials into handlebars compiler, which obviates Handlebars.registerPartial, just refer to other templates from inside your Handlebars templates and it'll just find them and use them

### Minor Changes
* added `kml` to list of default extensions
* #51, not adding public directory to directory structure with `mimosa new`.  Also not erroring out when it is not present.  Will create it if it is missing.

### You'll need to...
* You don't NEED to do it, but you might want to delete all your calls to Handlebars.registerPartial.  They should prove unnecessary.

# 0.0.27alpha - August 29 2012
### Minor Change
* #49, fixing pathing issues with compiled paths outside the project directory

# 0.0.26alpha - August 29 2012
### Major Changes
* Refactor of `mimosa new` in general
* Make choosing a server part of the prompt flow rather than a flag.
* Delivered server and routes now match chosen javascript compiler (server.js if JavaScript is chosen)

### Minor Changes
* fixed #47, issues with dropped in commonjs modules and incorrect recognition of dependencies
* fixed #46, maps and config paths, living together

# 0.0.25alpha - August 26 2012
### Major Changes
* `removeCombined` works again, #43
* #27, but bigger than that.  `mimosa watch` and `mimosa build` now both have a `--minify` option.  When `--minify` is used by itself, all compiled JS assets will be mangled and compressed using Uglify.  `--minify` has a new, small config in the mimosa-config that will let you exclude certain files from minification. By default, any file containing `.min.` will not be uglified, but you can adjust the settings to include more files. When `--minify` and `--optimize` are used in conjunction, the optimization (r.js) process will have uglification turned off (`optimize:'none'`).  In combination, `--minify` and `--optimize` allow you to control which files get mangled and still take advantage of the r.js optimizer zipping all your files together and wrapping them in Almond.  There are many cases where r.js optimization cannot be used because uglify breaks a given file.  The two combined options save you from needing a custom minification strategy in those instances.

### You'll need to...
* With the new `minify` section in the mimosa-config, you will no longer have an up to date, commented out, version of the mimosa-config.  It is suggested that you find a place in your config and paste this:

```
# minify:                               # Configuration for non-require minification/compression via uglify using the --minify flag.
  # exclude:["\.min\."]                 # List of excluded file regexes when running minify using the --minify flag.  Any file
                                        # possessing ".min." in its name, like jquery.min.js, is assumed to already be minified
                                        # in a way that preserves functionality of the library, so it will be ignored.  If you have
                                        # other files that you'd like to exempt from minification, overrides this property and
                                        # include them.
```

`minify` is a top level configuration parameter.

* If you were having trouble with the r.js minifier breaking your code, take a hard look at using `--minify` and `--optimize` together in combination with the `minify.excludes` option in the mimosa-config. [This commit](https://github.com/dbashford/AngularFunMimosa/commit/1816016a3444ab960dd79c2f65b63c6bf9fdc488) shows a good example of selective exclusion of files from uglification allowing the r.js optimization to occur. In that case optimization was entirely turned off because r.js does not allow you to exclude files from being uglified.  That commit re-enables uglifications and selectively omits the file that was causing trouble.


# 0.0.24alpha - August 24 2012
### Major Changes
* More strides towards Windows compatibility, including #42, requirejs alias directory path issues
* #39, `mimosa update` should now behave and install the correct versions of libraries

### Minor Changes
* #35, `mimosa virgin` should now be ok with requirejs path verification
* #41, shim validation had stopped working awhile back, is re-enabled
* #40, issues with plain JS + handlebars fixed

### You'll need to...
* Run `mimosa update` at any point?  It was broken, there's a chance you have versions of libraries installed that you ought not have. Now that it is fixed, it is best you run `mimosa update` again to get the correct versions.

# 0.0.23alpha - August 20 2012
### Major Changes
* Major strides in Windows compatibility thanks to @brzpegasus. Solved: issues with command line help, sass compilation, and pathing issues galore.  More to come.

### Minor Changes
* #13, updated to watch-connect 0.3.4 to handle problem with file renames/removes and live reload functionality
* #36, jade compiling to right directory

### You'll need to...
* Running with a server delivered by `mimosa new`?  Then run `mimosa update` from inside your project to get the latest watch-connect

# 0.0.22alpha - August 19 2012
### Major Changes
* #29, #30, new `require.optimize.inferConfig` setting.  If you do not want Mimosa to infer anything regarding your config set `require.optimize.inferConfig` to false.  Use this setting if you have a need to alter Mimosa's config far from the defaults.  Also use this setting if you are not using JavaScript based main modules (if you are putting your config on .html for instance).  All of Mimosa's default behavior for optimization relies on the existence of a javascript based main module. If there is no main module, optimization is not run.  This will continue to be the case unless `inferConfig` is set to false.
* #14, #15, and other things never logged as issues... updated requirejs from 2.0.4 to 2.0.6.

### Breaking Changes
* Prior to this version, requirejs optimization overrides went inside the `require.optimize` setting.  Those overrides now go into a `require.optimize.overrides` setting.

# 0.0.21alpha - August 16 2012
### Major Changes
* #28, `-D`, `--debug` option added to all commands.  Much debug logging added.

### Minor Changes
* #31, change in globber significantly impacted performance, so now using both globbers and switching on `win32`
* #32, added `--removeCombined` flag to `mimosa build` to allow for cleaning up after the optimizer
* Simple running `mimosa` at the command line will now bring up help instead of doing nothing

# 0.0.20alpha - August 14 2012
### Major Changes
* #25, replaced node-glob with node-glob-whatev, which purports to work better on Windows
* #23, turning verification off also made optimization not work, this should be fixed

# 0.0.19alpha - August 13 2012
### Major Changes
* #16, can now use live reload on multiple directories.  Add an `additionaldirs` array to the `reloadOnChange` options hash with the paths to the other directories you'd like to watch.  `mimosa new` will now will now deliver code that will watch the `views` directory.

### Minor Changes
* #18, prematurely killing interval resulted in builds ending too soon, don't kill until the compilers are done
* #22, almond appearing and disappearing should no longer bother mimosa projects with huge numbers of files

### Breaking Changes
* For those using the server code delivered by Mimosa, the `reloadOnChange` options hash `exclude` now takes an array of RegExp strings rather than an array of regular strings.  Be sure to escape your regex.

# 0.0.18alpha - August 12 2012
### Minor Changes
* #20, removing firefox debug info from stylus compiled files when optimized
* #!8, when throttling, build should now exit

# 0.0.17alpha - August 11 2012
### Major Changes
* Added `watch.throttle` config setting to provide throttling for large number of adds.
* Added ability to handle `requirejs` global from require.js library.  Previously was just handling `require`.

### Minor Changes
* Added 'yaml' as another default copy extension

# 0.0.16alpha - August 10 2012
### Minor Changes
* Fixed #17, when requirejs optimization throws, subsequent runs will not automatically also throw
* Mimosa will continue to recognize path directories from require config after a file has been deleted

# 0.0.15alpha - August 9 2012
### Minor Changes
* Remove package.json on volo add
* added default npm/gitignore on project creation
* fixed problem with LESS base file determination
* added support for verifying shim paths

# 0.0.14alpha - August 6 2012
### Minor Changes
* Fixed rushed version/publish
* fixed #12, handle path arrays/fallbacks

# 0.0.13alpha - August 6 2012
### Minor Changes
* Fixed #8, recognize plugin path
* Fixed #11, validate plugin path itself
* bug on template delete

# 0.0.12alpha - August 5 2012
### Major Changes
* RequireJS handling now manages and can correctly recognize your `map` config

### Minor Changes
* Many bug fixes in require path management

# 0.0.11alpha - August 2 2012
### Major Changes
* Added plain html templating

### Minor Changes
* vendor compiled css and js won't be linted by default, like bootstrap's LESS.  Is fix, adhering to existing setting.
* update watch-connect
* 'require' is a valid dependency

# 0.0.10alpha - August 2 2012
### Major Changes
* Added new command, `install` which will use volo to install dependencies from GitHub.

# 0.0.9alpha - August 1 2012
### Major Changes
* Use calculated require dependency graph as input to optimization, removes need to provide any config whatsoever for vanilla r.js optimizes.
* Added ability to have multiple base require modules that will be auto-detected and individually optimized based on items their dependency tree being updated
* included requirejs path verification in straight js copies for files not in vendor

### Minor Changes
* added use of jade partial to version of initial add delivered when jade is selected
* write to the console when a non-vendor file is detected not wrapped in either require or define block
* write a warning to the console when a circular require dependency is detected

### Breaking Changes
* The entire optimize defaults section of the [mimosa-config](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) is now gone as Mimosa will figure it all out for you.  Anything provided inside the optimize setting will overwrite anything Mimosa calculates.

# 0.0.8alpha - July 30 2012
### Major Changes
* added `jade` flag to `build` command that when provided will attempt to compile `index.jade`
* removed coffee-lint

### Minor Changes
* Upgraded Chokidar
* watch-connect back to npm

# 0.0.7alpha - July 28 2012
### Major Changes
* Added `update` command to make it easy for people to keep their dependent post-new-command modules up to date with Mimosa's skeleton

# 0.0.6alpha - July 27 2012
### Major Changes
* Added new RequireJS path verification ([see documentation](https://github.com/dbashford/mimosa#requirejs-support))

### Minor Changes
* Moved the require code around a bit in the Mimosa code base
* slightly altered the require code surrounding the client template libraries

### Breaking Changes
The `require` config has been broken up. What was previously directly under `require` is now under `require.optimize`.  A new `verify` option lives under the `require` config.

If you have not overridden any `require` configuration, then you are fine.  However, for future reference, it is suggested that you copy the new [mimosa-config.coffee](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) `require` block over top of yours.

If you have overridden the `require` configuration, then you'll want to adjust your current `require` object to be inside the `optimize` object, and you'll want to add the new `verify` option as it exists in the [mimosa-config.coffee](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee).
