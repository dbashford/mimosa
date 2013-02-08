# 0.9.0 - Feb ?? 2013

### Major Changes
* Mimosa now supports profile loading at startup for the `watch`, `build`, `clean` and `virgin` commands.  Those commands have a new `-P/--profile` flag that takes a string.  That string is the name of a Mimosa config file in a `profiles/` folder in the root of the project.  Profile files are simply `mimosa-config` files that override the main project `mimosa-config`.

  If this command,  `mimosa build -P jenkins`, is executed, Mimosa will look in the `profiles/` folder for a file named `jenkins.coffee` or `jenkins.js`, read that file in, and override the `mimosa-config` with the settings contained inside.

  The profile folder is configurable inside the root mimosa-config using a root level `profileLocation` property.  `profileLocation` must be relative to the root of the project.

* Mimosa now checks a 3rd scope for installed Mimosa modules: project scope.  Mimosa will work down the following path attempting to locate a module and stop when it finds it:
    1. Look in project scope
    2. Look inside Mimosa's global install
    3. Look inside the globally installed node modules
    4. Install the module from NPM into the global Mimosa install.

  If a module is, for instance, installed in all 3 spaces, Mimosa will use the project scoped module.

  Hopefully this update clears up a few issues folks have reported with shared resource issues across multiple concurrent Mimosa builds and permission problems with global installs.  Now if node and Mimosa are installed in a global protected space, a project can easily use Mimosa modules by executing, for instance, `npm install --save mimosa-web-package` from the project root which isn't typically a protected space.

### Minor Changes
* Mimosa will no longer look up the file structure attempting to find a mimosa-config.  If a mimosa-config isn't found in the current working directory, Mimosa will attempt to run in that directory using the default configuration.
* mimosa #134, fixing scope issue in jade-runtime client library

# 0.8.9 - Feb 01 2013

### Major Changes
* mimosa #129, TypeScript should now compile properly on Windows.

### Minor Changes
* mimosa #132, mimosa no longer writing empty compiled .d.ts files

# 0.8.8 - Feb 01 2013

### Major Changes
* Every mimosa module has been incremented, in most cases just to get the latest version of logmimosa
* mimosa-require #7, `require.optimize.overrides` can now be function. If it is a function, it is called after mimosa-require has built its inferred config.  This allows the overrides function to enhance the inferred r.js config rather than just replace it. As in the example below, mimosa-require creates an r.js config that includes an `include` array already. This added functionality allows additional includes to be pushed onto that array which keeps the original inferences in place.

```
  require:
    optimize:
      overrides: (rjs) ->
        rjs.include.push "foo"
```

### Minor Changes
* mimosa #126, when a module does not install, mimosa no longer keeps going. It will fail and will provide some helpful messaging to correct the problem.
* mimosa #128, remove dependency on globbing libraries
* mimosa #130, added "json","txt","xml","xsd" to list of default copy extensions
* mimosa #131, mimosa will now write empty files, but will warn they are empty
* logmimosa, setting and using process.env.DEBUG for registering debug mode
* mimosa-require has been updated to the latest requirejs.
* mimosa-require #8, added to the list of default r.js config settings is `logLevel:3` so that any errors will be written to the console. Obviously this can be overwritten if you do not want errors to be logged.
* mimosa-require, moved require based cleaning logic to mimosa-require module from core
* mimosa-skeleton #4, fixed issue with github clones not properly landing in the current directory.

# 0.8.7 - January 24 2013

### Major Changes
* mimosa #108, you are now no longer limited to bundling together all micro-template files into the same output file.  Bundling them all together makes perfect sense for a one page app, but once a 2nd page is introduced, you don't want all the templates in one place because you don't want to have to load every template everywhere.  An alternate config for the `templates` has been introduced.

```
# outputFiles: [{     # outputFileName Alternate Config 2
#   folder:""         # Use outputFiles instead of outputFileName if you want
#   outputFileName:"" # to break up your templates into multiple files, for
# }]                  # instance, if you have a two page app and want the
                      # templates for each page to be built separately.
                      # For each entry, provide a folder.  folder is relative
                      # to watch.javascriptDir and must exist.  outputFileName
                      # works identically to outputFileName above, including
                      # the alternate config, however, no default file name is
                      # assumed. An output name must be provided for each
                      # outputFiles entry, and the names must be unique.
```

Mimosa will bundle all the templates inside `folder` and write them to `outputFileName`.  `outputFileName` is identical to the current `outputFileName` and can be both of the alternate `outputFileName` configs.

`outputFileName` must be unique.  `folder`s can be nested.  You can have an entry where "app/foo" is turned into one file, and "app" is turned into another.

Future releases will allow multiple folders to be configured per output file to account for things like common site code.

### Minor Changes
* Update to mimosa-require to not attempt to remove remnants of build if there were no configs.  Hopefully fixes a bug with optimized builds that I was unfortunately unable to reproduce.
* Update to mimosa module handling to more gracefully error out/message when permission issues stop a Mimosa process from reading module files.
* A few library updates

# 0.8.6 - January 21 2013

### Major Changes
* mimosa-skeleton module released on 1/19. Now it just needs actual skeletons.  I'll probably create one or two, but will rely on skeletons being contributed down the road. If you build it they will hopefully come? mimosa-skeleton will become a default module once it has a few skeletons.
* mimosa-skeleton introduces 3 commands, `skel:new`, `skel:list` and `skel:search`. `skel:new` creates a new skeleton from the [registry](https://github.com/dbashford/mimosa-skeleton/blob/master/registry.json), from a github repo url, or from a system path (if testing skeletons). `skel:list` lists all skeletons from the registry. `skel:search` lists registry skeletons that match a provided keyword.
* To contribute a skeleton, just submit a pull request to get your skeleton added to the [registry](https://github.com/dbashford/mimosa-skeleton/blob/master/registry.json). I will curate the list ever so slightly. I don't care if you use Backbone or Ember or Angular or Batman, and I don't care how you organize your projects (that much)...but don't submit a Yeoman project. =)
* I'll also be adding some docs to the website in the next few days.

### Minor Changes
* Updated module skeleton to include updated logmimosa version
* mimosa #119, handling directories properly when determining initial file counts
* mimosa #124, allow any extension that has been registered for to pass through mimosas workflows

# 0.8.5 - January 15 2013

### Major Changes
* mimosa #123, got a pretty awesome pull request that will allow Mimosa to find and use Mimosa modules that are 1) installed globally if Mimosa is installed globally or 2) installed locally if Mimosa is installed locally.  Now you can install modules using `npm install` if you wish.  Mimosa will still auto-install any modules listed in the `mimosa-config` if Mimosa cannot find them.

# 0.8.4 - January 14 2013

### Minor Changes
* mimosa #121, handling spaces in the path for `mod:install` command.

# 0.8.3 - January 13 2013

### Minor Changes
* mimosa-import-source #1, handling problem in mimosa core where source file counts were not being updated after code was imported from mimosa-import-source.  Also fixing issue where orphan imported folders were preventing non-imported folders from being cleaned up.
* mimosa-web-package #1, fixed web-package code dependency on mimosa-server

# 0.8.2 - January 12 2013

### Minor Changes
* mimosa #113, logmimosa logging functions now take varargs, much like console.log, ex: `logger.info("foo", bar, false)`
* mimosa #116, added makefile to starter skeleton
* mimosa #117, added `htm` to the list of copy extensions.
* mimosa #118, removed `preferGlobal` setting from all the modules and from module skeletons, all modules have been released with bumped versions
* mimosa-server #2, for the default server, allowing any and every path not to static assets to route to the app's index

# 0.8.1 - January 10 2013

### Minor Change
* Fixed pathing issue introduced with `0.8.0`

# 0.8.0 - January 10 2013

This update is shallow, but wide.  Every module has been updated, and there are a few breaking changes, so check the "You'll need to..." section below.  Big updates to mimosa-lint, big reduction in module code overall as validation logic for module configuration has been centralized.

### Major Change
* mimosa #112, servers now must call a provided callback and hand that callback the server instance and the instance of socketio.  This increases flexibility and allows server support to handle servers that start asynchronously.
* core, module `validation` function will now be passed a 2nd parameter that will consist of several validation methods, like `isString` and `ifExistsIsBoolean` as well as more complex validations like `isArrayOfStringsMustExist`.  These functions cut down immensely on what was a growing amount of duplicated code in module validation across modules.  Hopefully eventual module authors will find the functions useful, but they certainly will speed up my own development of modules.  See the [validation source code](https://github.com/dbashford/mimosa/blob/master/lib/util/validators.coffee) to see all of the validation functions available, and if you want more, just ask!
* Every published mimosa module has been updated to use the new validation functions. Because of this, the latest version of the modules can only be used with v0.8.0+ of Mimosa.

### Minor Change
* core #114, fixed iced coffee script support, still more work to make it perfect (see #115)
* core, fixed issue with mimMimosaVersion
* core, added `htc` and `ico` to list of default copy extensions
* core, updated module skeletons to include validation object
* mimosa-lint #1, added an `exclude` property to lint config
* mimosa-lint #2, added jshintrc support
* mimosa-lint #3, added default values for coffeescript and icedcoffeescript linting
* mimosa-lint #5, code will look up the file system looking for .jshintrc file.  If it doesn't find one in the project directory, it will work its way back down to the root of the file system attempting to find one.
* mimosa-import-source #2, fixed issue deleting file after mimosa started up

### You'll need to...
* Change your `startServer` function to take a 2nd parameter that is a callback function.  Instead of returning values from `startServer`, the callback needs to be executed and the server and socketio instance, in that order, should be provided to the callback.
* Older versions of Mimosa (pre-0.8.0) will not be able to use the latest version of the modules.  Older versions of the modules can be used with the latest Mimosa.  So, as long as you keep your Mimosa up to date there's nothing to fear!
* Using mimosa-lint for linting your coffeescript or iced coffeescript?  Then there is a good chance you've added a few rules to your mimosa-config because of the nature of the JavaScript that the coffeescript compiler outputs.
```
rules:
  javascript:
    boss: true
    eqnull: true
    shadow: true
```
You can remove those now.  The latest versions of mimosa-lint (both 4.0 and 5.0) assume those three rules when jshint-ing compiled CoffeeScript and IcedCoffeeScript.
* If you might have been in the process of building your own module, you'll want to take advantage of the 2nd parameter being passed to the `validate` function.

# 0.7.3 - January 05 2013

### Major Changes
* Mimosa modules that introduce new commands can now request mimosa execute a clean and build before running.  So now commands that need to can operate on a fully built codebase, like, for instance, a `test` command.

# 0.7.2 - January 05 2013

The next set of changes I have planned will be fairly breaking in nature, so I wanted slide this mostly non-breaking release out. A few small tidbits, fixes and updates. This release also sets the stage for future modules that will not only add functionality to Mimosa workflows, but also introduce entirely new Mimosa commands.

### Major Changes
* Updated libraries in Mimosa and in all the modules resulting in updated versions for every module.
* Added the ability for a Mimosa module to add a command to Mimosa.  Now modules are no longer limited to working within a workflow. New commands can be added. Mimosa will pass a [commander](https://github.com/visionmedia/commander.js/) `program` object to a module as well as a function that can be used to retrieve the full `mimosa-config` should that command get invoked.  More details on the [modules page](http://mimosajs.com/modules.html) of the mimosa website.
* Utilizing the ability to have modules introduce commands, the `import` command has been pulled out of the Mimosa core codebase and into a mimosa-volo module.  The functionality is the same.  But now to use it it must be installed: `mimosa mod:install mimosa-volo`.  This paves the way for a possible future [bower](https://github.com/twitter/bower) or [component](https://github.com/component/component) related modules.
* Changed the `update` command to `refresh` to differentiate it from `npm update/install`.  Too many folks have confused the `mimosa update` with `npm update`, erroneously thinking that the command updated Mimosa itself rather than the packages in their own project.

### Minor Changes
* mimosa #109, Omit comments in compiled template file when using the `optimize` flag.
* mimosa #111, fixed crash on css preprocessor file movement
* mimosa, Added `.gitignore` to module skeleton that omits `node_modules` now that module installs run `npm install` locally to verify install.
* mimosa, cleaning should now do a better job of removing empty folders from the `watchDir`
* mimosa-server-template-compile #1, module now cleans up after itself
* logmimosa, removed new lines from growl message as growl library doesn't support it

### You'll need to...
* If you were using `mimosa import`, it is now no longer a part of mimosa core and needs to be installed separately.  `mimosa mod:install mimosa-volo`

# 0.7.1 - December 24 2012

Tiny update, been taking a much needed break for the holidays, but squeezed a few things in.  I'll be back at it in the new year with skeletons, new server options for `mimosa new`, big updates for the mimosa-lint module, and a consolidation of the module validation logic for reuse purposes.  And most likely requirejs source map stuff too.

### Major Changes
* New base config parameter `minMimosaVersion` indicates what version of Mimosa is expected for the project running with that `mimosa-config`.  If a `mimMimosaVersion` is set to `0.7.1` and the local install is for `0.7.0`, mimosa will log an error and not start. This makes it easy for a single person on a team to upgrade and validate a given Mimosa install, and then enforce its use across the project team.

### Minor Changes
* mimosa #101, Added `-d/--delete` flag to `mimosa watch` that allows one to completely remove the `watch.compiledDir` before anything else occurs.  Ex: `mimosa watch -d`
* Removed some leftover logging from sass compiler
* mimosa-require #6, commented out all debug logging, should speed up verification quite a bit.
* mimosa-combine #5, removed validation from folder path.

# 0.7.0 - December 17 2012

### TypeScript
Added preliminary TypeScript support. Mimosa's TypeScript compiling is currently for web assets, not server assets. There is probably an opportunity to have compilation of server assets to occur via an external module, but I haven't spent a lot of time thinking that through. For the time being, when running `mimosa new`, if TypeScript and Express are chosen, the delivered server assets are JavaScript.

I'm not a TypeScript developer, I've only dabbled and played. So there are likely options the TypeScript compiler needs to support that it is not.  I need feedback from TypeScripters on that.

Lastly, the trivial TypeScript web assets delivered with `mimosa new` are far from idiomatic TypeScript. If someone wants to help out with that...https://github.com/dbashford/MimosaTypeScript

### Major Changes
* You can now list specific versions of modules in the `modules` array in the `mimosa-config`. For folks working on multi-person projects, this'll let a single person update the mimosa-config to specific (usually newer) versions of Mimosa modules, and the other members of the team need not worry about installing those versions themselves.  When Mimosa starts, if it detects it has modules with versions that vary from the versions listed in the `modules` array, it will install the desired version from NPM. To use a specific version, add `@` followed by the version. Ex: `require@0.5.0`
* Removed `removeCombine` flag from `mimosa build`.  Mimosa will now always remove all the files involved in the r.js run when the `--optimize` flag is used during `mimosa build` and it will not use r.js' removeCombined to do it.  Relates to mimosa-require #3.
* Removed the `jade` flag that was a part of `mimosa build`.  The limited functionality behind that flag is now part of the `mimosa-server-compile-template` module. Server template compiling is no longer limited to Jade, no longer limited to a single file, and no longer hard-coded to pass in certain values.  This new module will let static sites be built using dynamic templates, and in time the Mimosa website will move over to being built with Mimosa thanks to this new plugin. https://github.com/dbashford/mimosa-server-template-compile
* mimosa #90, upgraded default exclude to `/[/\\](\.|~)[^/\\]+$/` to cover a wider range of temp/dot/backup files, also fixed hidden issue where CSS and template compilers were ignoring `watch.exclude`
* mimosa #96, added handlebars as a server template option
* mimosa #82, fixed problem where modules could not be upgraded using `mod:install` alone
* `mimosa build` now executes a clean prior to building.

### Minor Changes
* mimosa-require #1, fixed `inferConfig: false` code path
* mimosa-require #2, r.js `out` can now be removed from config
* mimosa-require #4, upgrade almond to latest version
* mimosa-require #5, require overrides from `mimosa-config` were remaining frozen when sent to r.js
* mimosa-live-reload #1, client script now cleaned up upon `mimosa clean`
* mimosa-server-reload #1, added defaults to `watch` config
* mimosa #13, handling files not existing
* mimosa #94, when clean finishes, exit hard, don't wait for program to finish on its own
* mimosa #95, default README for `mimosa mod:init`
* mimosa #97, added a few more things to skeleton `.gitignore`
* mimosa #99, `mimosa config` command will no longer overwrite an existing config in same directory
* mimosa #100, handling directory moving
* mimosa #104, tweaked mimosa-combine module to append a semi-colon after combined `.js` files
* Removed needless dependency on lodash in mimosa-lint
* You can now disable a compiler by setting it to `null` in the `extensionOverrides` setting, for instance if you didn't want to compile a certain type of file, but instead wanted to just copy those files verbatim.  So if you wanted to copy `.dust` files rather than have Mimosa compile them for you, you'd add `"dust"` to the list of `copy` extensions and then turn the dust compiler off like so:
```
compilers:
   extensionOverrides:
     dust: null
```
* simplified and consolidated `mod:install` code
* mimosa-minify upgraded to the latest uglify.  I've done all the work to figure out source maps, but commented out the source map related code for future use as it doesn't make much sense given the current use of uglify

### You'll need to...
* Update your `watch.exclude` to have the default of `[/[/\\](\.|~)[^/\\]+$/]`
* Were you using `removeCombined`?  It's no longer available as a flag.  Its functionality will be the default functionality whenever the `optimize` flag is used during a `mimosa build` run.
* Were you using the `jade` flag with the `mimosa build` command?  It is now gone.  You'll want to use the `mimosa-server-template-compile` module instead.

# 0.6.2 - December 02 2012

Due to the holiday and me attending a conference all week this release took a bit.  With a bunch of the backlog a few more releases this week are likely.

### Major Changes
* New module, `mimosa-import-source`, see the module's README for details https://github.com/dbashford/mimosa-import-source

### Minor Changes
* Added new workflow before everything starts called `preBuild`.  Has two steps for now, `init` and `complete`.  Steps always easy to add.  This workflow is executed before `buildFile`, so before any individual assets are considered.
* Added `preClean`, `cleanFile`, `postClean` workflows and redirected all current cleaning behavior to use `clean`.
* Changed name of `buildDone` workflow to `postBuild` and changed all modules that registered for `buildDone` to use `postBuild`
* mimosa-require-commonjs #1, added return to end of wrap
* reworked modules page on site

### You'll need to...
* If you are doing any module work, you'll want to change your workflow details to match the new names

# 0.6.1 - November 23 2012

### Minor Changes
* Fixed #87, excluding paths via `watch.exclude` not working properly.  `watch.exclude` paths not exclude anything that starts with that path.  So you can point at a directory and anything within that directory (recursive) will be excluded.

# 0.6.0 - November 21 2012

Leaving beta. Plenty still to do, but its been decently shaken out at this point.  This release opens up the door to manipulate the r.js configuration to dynamic runtime updates.

### Major Changes
* Added EJS support for client templates.
* Big upgrade to interface for `mimosa-combine` module, released as 0.2.0 on Nov 16th
* Pushing to latest version of `mimosa-require`.  Latest version of that module pulls building of r.js run configs, and execution of r.js runs into 2 different steps in the workflow.  This means that modules can jump in the middle, programmatically and dynamically changing the r.js run config that `mimosa-require` generates before it executes.  This further empowers users of Mimosa to take control over the r.js runs.  A module can be custom built to alter the config to do just about anything.
* Added a module demonstrating the above: https://github.com/dbashford/mimosa-requirebuild-textplugin-include
* New module, `mimosa-server-reload`, for those running own node/express server, will restart server when server resources change.  https://github.com/dbashford/mimosa-server-reload
* Details below under minor changes, but across the board `mimosa-config` paths can now be both relative and absolute, and `mimosa-config` string regexs (and arrays of string regexs) are now just regexs (and arrays of regexs), which eliminates the extra escaping.

### Minor Changes
* Upped to latest versions of `server`, `live-reload` which support `server-reload`
* #85, fixed issue with windows config file detection
* To allow for workflow tasks to space out a bit more, added `betweenWriteOptimize`, `beforeOptimize`, `optimize`, and `afterOptimize` as new steps in the `add`, `update`, and `remove` workflows
* With v0.2.0 of `mimosa-web-package`, `outPath` can now be absolute as well as relative to the root of the folder.
* With v0.2.0 of `mimosa-require-commonjs`, `exclude` can now be expressed as an array containing all of the following: regex, string path relative to `watch.javascriptDir`, and/or absolute string path.  Previous is was only allowed to me a list of regex strings...not regexs.
* With v0.4.0 of `mimosa-minify`, `exclude` can now be expressed as an array containing all of the following: regex, string path relative to `watch.compiledDir`, and/or absolute string path.  Previous is was only allowed to me a list of regex strings...not regexs.
* With v0.4.1 of `mimosa-live-reload`, the `additionalDirs` config can take both absolute and relative paths to folders.
* `watch.sourceDir` and `watch.compiledDir` can now be absolute in addition to being relative to the project root.
* `watch.exclude` is now an array of regexes and strings.  Strings are paths and can be relative or absolute.

### You'll need to...
* If you were using `mimosa-combine`, take a look at the latest documentation and see if you want to upgrade to 0.2.0.  The interface is now a good deal more flexible.
* For `mimosa-require-commonjs`, the `minify` config, and the `watch` config, if you overrode exclude, your string regexs need to turn into real regexs.  Ex: ["/foo/"] => [/foo/].  And you can now use string paths, both relative and absolute.

# 0.5.5beta - November 15 2012

Purely bug fixes, both for the mimosa-require module.

### Minor Change
* Fixed #83, didn't recognize main module when it lacked config
* Fixed issue in `mimosa-require` module where workflow next callback was being called too soon.

# 0.5.4beta - November 14 2012

### Major Change
* New module `mimosa-combine`, an external module that has to be installed, not a default one, will take a folder and merge the file contents into a single file.  All configurable.  Details: https://github.com/dbashford/mimosa-combine
* New command `mod:config` will write the default configuration snippet for any module.  Ex: `mimosa mod:config server` will output the config snippet for the `mimosa-server` module.

### Minor Change
* Very tiny reorg to some module code to enable the `mimosa-combine` work

### You'll need to...
* To use the new module, simply add it to the list of modules in your `mimosa-config` or use `mimosa mod:install mimosa-combine`.  Once it is installed, use the new `mimosa mod:config` to print the config to your console so you can copy/paste it into your mimosa-config.

# 0.5.3beta - November 13 2012

Phase1 CommonJS support.  Not pure CommonJS, but CommonJS via AMD/RequireJS.  For those of you who just can't stomach wrapping all your code, but would love to take advantage of all that RequireJS provides, Mimosa can help.

### Major Changes
* CommonJS support via AMD/RequireJS using the `mimosa-require-commonjs` module.  For details: https://github.com/dbashford/mimosa-require-commonjs

### Minor Changes
* Upgrade version of `mimosa-require` to support `mimosa-require-commonjs`
* Fixed issue with requirejs plugin paths that had no dependency after the !.  Ex: `vendor/domReady!`
* #81, addressed `mimosa update` installing a bunch of stuff it not ought to have

# 0.5.2beta - November 11 2012

More minor updates while I am busy working on both TypeScript and CommonJS support.

### Minor Changes
* `mimosa-live-reload` and `mimosa-server` modules have been updated to handle the case where a user's project is already using socket.io.  If you are using socket.io on your own, using live reload, which also binds socket.io to your server, can cause some issues.  The `startServer` function in your server file, to use live reload, should currently be returning the server.  `startServer` can continue to do that if you do not need to use socket.io on your own.  If you need to use socket.io, `startServer` should return this object `{server:server, socketio:io}`, where `server` is what `startServer` returns currently, and `io` is the object returned by `socketio.listen(server)`.
* Updated the `logmimosa` version in the module skeletons.

### You'll need to...
* If you are using `mimosa-live-reload` and want to use socket.io, update your `startServer` function so that it returns `{server:server, socketio:io}`, where `server` is what `startServer` returns currently, and `io` is the object returned by `socketio.listen(server)`

# 0.5.1beta - November 09 2012

Small bug fixes. Library updates. Other miscellany.

### Minor Changes
* Library updates across the board, both in core and in the modules
* updated jquery and requirejs in the `mimosa new` skeleton
* Fixed middleware ordering issue in the delivered express server
* `mimosa config` and `mimosa new` will now rewrite your `mimosa-config` `modules` array to use whichever modules you have installed.  Previously those commands would leave the default placeholder in place for the `modules` array, but include all the config placeholders for all installed modules.

### You'll need to...
* If working with an application skeleton delivered by `mimosa new`, you'll probably want to perform the changes from this commit: https://github.com/dbashford/mimosa/commit/c97f91884ad35f34a790378ba83d8db9ce40af81 most notably the moving of the router to below the configure blocks.

# 0.5.0beta - November 06 2012

This release has a small amount of changes, but they have a decent number of breaking changes from beta4.

### Major
* In beta4 and previous, the `mimosa-server` module had live-reload functionality built in.  That functionality has been broken out of `mimosa-server` and placed into a new module, `mimosa-live-reload` which is now a default module installed with Mimosa.
* The live-reload functionality itself has been drastically altered.  No longer does Mimosa depend on another library (`watch-connect`) to provide the functionality, it has been included entirely in `mimosa-live-reload`.
* Projects that have their own server will no longer need any live-reload code in their codebase other than to include the flag in their server views to turn live-reload on and off. Mimosa handles everything else internally.  This means a lot less boilerplate code to deliver and for users to maintain in their Mimosa-based projects.
* Also, changed CSS files no longer cause a full browser reload.  Instead just the CSS is updated and repainted in the browser. So if you are developing a big single page app, no more having to start over in a page flow from page A to see CSS changes on page E.

### Minor
* Mimosa now attempts to load locally installed modules before installing them within Mimosa. If the module doesn't load (bad CoffeeScript syntax, bad require path, etc), Mimosa will not install it.  Previously, bad modules could be installed and that would cause Mimosa to be unable to subsequently start.  This does not stop bad modules from being loaded from NPM, just locally.
* Modules can now only change properties from their own config within the `mimosa-config`, both during validate() function, and during workflows.
* The default `mimosa mod:init` skeleton is now JavaScript.  With a `--coffee` or `-c` flag you can get a CoffeeScript module skeleton.

### You'll need to...
* A few changes to your codebase, see the next few bullets for details, and this commit for an idea of the sort of changes you'll need to make: https://github.com/dbashford/mimosa/commit/d21c182ff903e226d387bf8844a5580a251b4c03
* Swap the order of the live-reload scripts and the requirejs scripts in your server templates.  The live-reload scripts should be first.
* Change the name of the `/socket-enable.js` script to `/javascripts/reload-client.js`
* All of the live-reload related code can be removed from your `server` file.  This includes the `require 'watch-connect'` and the `if useReload` block.
* Replace any references to `config.server.useReload` to `config.liveReload.enabled`
* The `startServer` function needs to return the server object returned by `app.listen()`.  Without this live-reload will not work.
* The configuration for live-reload has moved.  There is no longer a `server.useReload` property.  There is now a top level `liveReload` object. Include the config snippet for the `mimosa-live-reload` module in your `mimosa-config`:

```
# liveReload:                   # Configuration for live-reload
  # enabled:true                # Whether or not live-reload is enabled
  # additionalDirs:["views"]    # Additional directories outside the watch.compiledDir
                                # that you would like to have trigger a page refresh,
                                # like, by default, static views
```

* The new default list of modules now includes `live-reload`, so you'll want to either copy the new commented out config for future use, or update your list if you've uncommented it already.

```
# modules: ['lint', 'server', 'require', 'minify', 'live-reload']
```

* The dependency on `watch-connect` is gone, so it can be removed from your `package.json`.


# 0.4.1beta - November 02 2012

### Major
* Added a `--package` flag to `mimosa build`, this does nothing other than add an `isPackage` flag to the `mimosa-config`.
* Created a new module `mimosa-web-package`, that will package up a web application. See the github repo for details: https://github.com/dbashford/mimosa-web-package  Naturally, this works with the new package flag is ticked on.  This module is not a default module, but can be used by uncommenting the `modules` config and adding `web-package`
* I've locked down the mimosa-config via Object.freeze().  Now that the app is open to module development, I felt it fairly important to keep this immutable. Now modules cannot modify the config.  I encourage the use of "use strict" in your modules so you have errors thrown when you attempt to modify the config. The module skeleton now uses "use strict". You can still alter any part of the config during the call to `validate(config)` inside a module, but that will be limited to just the portions of the config belonging to a module in a future release.

### Minor
* Upgrade all modules and the module skeleton to use the latest logmimosa.
* Added coffee-script as a dependency for mimosa's 'new' skeleton when CoffeeScript is selected as the language of choice.
* Beginning to sprinkle "use strict" around codebase.

### You'll need to...
* If you have a CoffeeScript app, for the new package module to work, you'll need to add "coffee-script": "1.3.3"  (or 1.4.0) to the list of dependencies in your `package.json` and then run `npm install` from the root of your project.

# 0.4.0beta - October 31 2012

Pluggability has arrived.  Obviously Mimosa is new and therefore its use isn't widespread, so there aren't modules besides the core set that come with Mimosa for you to use. But as time passes, I'll be building more, and in a perfect world a community of sorts develops and chips stuff in too. This release enables that.

This is another low breaking-changes release.  Don't need to do much to upgrade.  A few minor things listed below.

beta5 will be a return to adding features that have been building up while module work has commenced. Not terribly far from a 1.0.

### Major
* The `install` command has been renamed to `import` to make way for possible future different use of `install`.
* http://mimosajs.com/modules.html , modules/extensibility added and documented, few highlights...
* A new top level configuration property `modules` has been introduced.  It defaults to ['lint', 'server', 'require', 'minify']. This is what it needs to be for Mimosa to keep on doing what it always has for you, so you can leave it at its default. The modules property is how you tell Mimosa what modules to use. The default modules are external to Mimosa, but are installed with Mimosa by default.
* You can choose to remove `modules` from your project if you feel you don't need them.  For instance, if you don't want to lint your code, remove the `lint` module from the list and remove the `lint` config. This saves you having to turn if off using the lint config itself.  (In this example, if it is all commented out, you don't have to remove the lint config, but if you aren't using it, may as well clean it up!)
* You can also add new modules, modules outside the core set of Mimosa modules.  As of this writing none exist, but the point of making Mimosa pluggable was to allow for them to exist and be used.  If someone coded a `mimosa-foo` module and installed it in NPM, you can add `foo` to the list of modules. Mimosa assumes the required `mimosa-` prefix.  Mimosa will self-install any modules it finds in your list.  If it comes across a module it doesn't recognize, it will make a trip to NPM to find it.  If it doesn't find it there, it will error out.
* An entire set of commands around modules have been introduced.  They are all underneath a `mod:` prefix.

  * `mod:init [name]` - if you are interested in creating a module, this creates a module skeleton for you to use complete with heavily commented code and including docco'd docs for that code.
  * `mod:search` - This command scans npm for any `mimosa-` modules in the registry and gives you some information about them.  Use a `--verbose` flag to get more information.
  * `mod:list` - This lists all the modules installed within your Mimosa. Use a `--verbose` flag to get more information.
  * `mod:install` - This will install a Mimosa module into your Mimosa.
  * `mod:uninstall` - This will uninstall a Mimosa module from your Mimosa.

### Minor Changes
* You can now use a `mimosa-config.js` if you want. Mimosa will not give you one of those with `mimosa new` or `mimosa config`, but you can make the minor necessary charges and alter the extension of the file and Mimosa will pick it up.
* gzippo branch used as dependency with past versions of Mimosa is now gone, which will force you to upgrade/remediate as indicated in previous release
* mimosa-logger is now logmimosa to distinguish it from actual modules.  mimosa-logger will be removed from NPM to save confusion.

### You'll need to...
* At the very least, add the commented out lines of config for modules so should you want to update modules later, its there and easy to update.
```
# modules: ['lint', 'server', 'require', 'minify']   # The list of Mimosa modules to use for this application. The defaults
                                                     # (lint, server, require, minify) come bundled with Mimosa and do not
                                                     # need to be installed.  The 'mimosa-' that preceeds all Mimosa module
                                                     # names is assumed, however you can use it if you want.  If a module
                                                     # is listed here that Mimosa is unaware of, Mimosa will attempt to
                                                     # install it.
```

* Make modules of your own!  `mimosa mod:init mimosa-[nameOfModule]` and get crackin'!  Check out http://mimosajs.com/modules.html for details.
* mimosa-logger will be removed from NPM shortly, so you'll want to be sure you aren't using it.


# 0.3.1beta - October 22 2012

### Minor Changes
* Hot fix for #78.  0.3.0beta introduced an issue with user config overriding default config.

# 0.3.0beta - October 22 2012

Another step towards pluggability.  Much code yanked out of mimosa core and placed into separate npm modules (all prefixed with `mimosa-`, and easily searchable in npm by searching for `mmodule`, for 'mimosa module').  The work to do that paves the way for external modules/plugins which will be the subject of beta4.

### Major Changes
* linting, logging, serving, minifying and require/amd support have been pulled out into separate modules/plugins that are now their own npm modules. These are included as dependencies by default with mimosa. But now they can be versioned on their own, tested on their own, and so on. Each of those modules defines its own defaults, its own config placeholder (the commented out version of the config, with description, etc), and its own validation. Validation has been beefed up significantly as has feedback regarding an invalid config.
* The default config is now built on the fly based on the installed modules.  For now it'll resemble if not match what it would have been previously, but as new modules or external plugins are added, this'll allow the config to adapt.
* `watch.ignored` is now called `watch.exclude` and now takes regexes. The default has changed from `[".sass_cache"]` to `["[/\\\\]\\.\\w+$"]`.  The new default omits any files starting with a slash + a dot, like `.gitignore` or `.DS_Store`.

### Minor Changes
* Mimosa takes some of your command line flags and places them into the mimosa-config.  Two of those changed names.  `min`, a boolean that indicates whether or not the `--minify` flag was ticked, is now named `isMinify`.  `optimize`, a boolean that indicates whether or not the `--optimize` flag was ticked, is now named `isOptimize`.

### You'll need to...
* If you were overriding the `watch.ignored` property, you'll need to change it to `watch.exclude` and then address the value based on the new default.  If all you were doing with `watch.ignored` was excluding dotFiles, like `.gitignore`, then you can simply comment out the config setting as that is the new default.  If you were ignoring other things, take care to address the fact that the property now takes an array of regex strings.
* If you were not overriding the `watch.ignored` property, you will still probably want to change the placeholder text to keep from future misunderstandings should you need to exclude files.  Run `mimosa config` someplace outside your project and copy paste the updated, commented out property placeholder.
* The skeleton app delivered to you might have references to `config.optimize`
 in it that need to be changed to `config.isOptimize`.  Likewise, if for some reason you were taking advantage of `config.min`, you'll need to switch it to `config.isMinify`

# 0.2.2beta - October 18 2012

### Major Change
* #76, fixes fairly critical issue involving excluded files.

# 0.2.1beta - October 18 2012

### Major Changes
* #75, addressed LiveScript problem

### Minor Changes
* Moved server code into buildDone workflow

# 0.2.0beta - October 15 2012

### Colossal Change & Roadmap

Beta 1 to 2 was an entire refactor of the guts of Mimosa.  Pre beta2, an asset's workflow was tied tightly to compilers.  Calls to lint, calls to minify, calls to deal with amd/requirejs, etc, were all contained in the compilers.  It was a bit messy and with beta 1 decently featureful, I wanted to take the time to pull all of that apart.  What this will allow, and you'll see in beta3, is the detaching of some of that code from Mimosa entirely, putting it instead is separate npm modules to version, maintain, and eventually test apart from the larger Mimosa codebase.  Also in the next few betas one will be able to write their own modules that will be able perform tasks at certain points of an asset's workflow.

Despite many urges to the contrary, I tried not to add any new features as I wanted this refactor to be as seamless an experience from an Mimosa interface perspective as possible.  So, in all cases except for the gzippo case below, you should need to do nothing to upgrade from beta1 to 2 other than reinstall Mimosa.  beta3 should largely be the same.  I'll be pulling code out of Mimosa, and moving some things around, but there should be very few breaking changes.  beta4 will likely be a return to feature development and I've got quite the backlog of stuff building up.

Please do eagerly report any bugs you find with this release.

### Major Changes
* Removed gzippo as a dependency and use express.compress in its place.  Way more stable and fewer dependencies is goodness.
* New LiveScript compiler courtesy of @semperos

### Minor Changes
* Various messaging updates for consistency.

### You'll need to...
* If you were using gzippo in your server, it is recommended you remove it. I'll be deleting my fork sometime soon. See this commit: https://github.com/dbashford/mimosa/commit/172c2c89190bfa3b50249bfe4036cdb7f05bee1b#L3L1 to get an idea of the very simple changes you'll need to make which include removing the require for gzippo and therefore allow you to remove gzippo from your `package.json` as well.

# 0.1.2beta - October 11 2012

### Minor Changes

* #73, gzippo not pointing at fixed fork, would have caused mimosa hosted server to fail in many cases

# 0.1.1beta - October 2 2012

Still pushing forward on beta2 which, now that Mimosa is baseline feature complete, includes a massive re-write of Mimosa's internals.  Still likely a few weeks away on that.  But meanwhile...

### Minor Changes

* #72, the SASS compiler was complaining about not being installed even if no SASS was being used or compiled.  Now mimosa will only report SASS not being installed if SASS compilation is attempted.

# 0.1.0beta - September 19 2012

Beta entered! Going to be working on some bigger things for beta2 over the next few weeks and only releasing any necessary bug fixes and non-breaking features. So releases will slow down quite a bit, but that doesn't mean I'm not busy. =)

### Major Changes
* Upgraded all of Mimosa's own dependent libraries to their latest versions.
* Upgraded the skeleton express and jade to their latest versions

### Minor Changes
* #48, fixed an issue with templates using requirejs config paths.

### You'll need to...
* Entirely optional, but if you are running with your own server, you may want to run `mimosa update` to get the latest express and jade installed in your app.
