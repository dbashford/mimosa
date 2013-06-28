# 0.13.9 - Jun 27 2013

### Minor Changes
* [mimosa #225](https://github.com/dbashford/mimosa/issues/225). Now recognizing amd/requirejs depedencies declared in `require`/`require.config` `deps` property.

# 0.13.8 - Jun 26 2013

### Minor Changes
* [mimosa #222](https://github.com/dbashford/mimosa/issues/222). Using new iced-coffee-script with proper semver-sioning.
* [mimosa-combine #9](https://github.com/dbashford/mimosa-combine/issues/9). Fixed bug with error being thrown for files inside directories. Released June 26.

# 0.13.7 - Jun 26 2013

### Minor Changes
* Dependent library updates

# 0.13.6 - Jun 25 2013

### Major Changes
* [mimosa #198](https://github.com/dbashford/mimosa/issues/198). `virgin` command has been removed.  New versions of `mimosa-client-jade-static` and `mimosa-require` released after removing `virgin` references.

### Minor Changes
* [mimosa-combine #7](https://github.com/dbashford/mimosa-combine/issues/7). Fixed bug causing ordered files to not be cleaned up.
* [mimosa-combine #8](https://github.com/dbashford/mimosa-combine/issues/8). Fixed bug causing empty directories as result of combine cleanup not being cleaned up.

# 0.13.5 - Jun 23 2013

Big changes/additions/fixes to the Stylus compiler with this release.

### Minor Changes
* [mimosa #224](https://github.com/dbashford/mimosa/issues/224). Better error message when cannot parse `.jshintrc` file
* [mimosa #221](https://github.com/dbashford/mimosa/issues/221). Mimosa now builds locally on Windows.
* [mimosa #216](https://github.com/dbashford/mimosa/issues/216), [mimosa #173](https://github.com/dbashford/mimosa/issues/173). Stylus `import` config is now available to be tweaked by the `stylus` root level config.  Previously the `import` config was automatically set to the same libraries as `use` was.  By default, the `import` config, an array, is set to `['nib']`.
* [mimosa #216](https://github.com/dbashford/mimosa/issues/216). Stylus `define` config available via the `stylus` root level config.
* [mimosa #216](https://github.com/dbashford/mimosa/issues/216). Stylus `include` config available via the `stylus` root level config.
* [mimosa #215](https://github.com/dbashford/mimosa/issues/215).  Fixed issue where `stylus.use` could not be set to an empty array.

# 0.13.4 - Jun 20 2013

### Minor Changes
* [mimosa #220](https://github.com/dbashford/mimosa/pull/220), [mimosa #218](https://github.com/dbashford/mimosa/issues/218). Adding back ansi-color require which got dropped this morning and was causing issues for folks who didn't have SASS installed.

# 0.13.3 - Jun 20 2013

### Major Changes
* mimosa. Mimosa now places modules into the config more easily allowing modules to use one another.

### Minor Changes
* mimosa-server-reload. Updated to refer to other modules via config.
* mimosa. Mimosa no longer freezes the configuration at any point.  Proved to be more trouble than it was worth.
* [mimosa #217](https://github.com/dbashford/mimosa/pull/217). Via PR added Travis, and using Mimosa to build withing having it installed.

# 0.13.2 - Jun 13 2013

### Major Changes
* mimosa/mimosa-minify. A bit of a toy feature, but the `mimosa-minify` module now supports two-step source maps with CoffeeScript.  CoffeeScript -> JavaScript -> minified/mangled JS, with source maps all the way back to the CoffeeScript.  Try it out!  In a CoffeeScript project run `mimosa watch -sm`, notice minified/mangled JS gets delivered to the client.  Break some CoffeeScript, go back to the browser, check the console and notice that the error points you back to the original line of CoffeeScript that caused the breakage.  Good stuff!
* [mimosa #214](https://github.com/dbashford/mimosa/pull/214), [mimosa #196](https://github.com/dbashford/mimosa/issues/196). PR to add [Coco](https://github.com/satyr/coco) support including assets for `mimosa new`.

### Minor Changes
* mimosa. Source map names now follow the `.js.map` convention.  Previously they were named simply `.map`

# 0.13.1 - Jun 10 2013

### Minor Changes
* mimosa. Fixing ECO scaffold templates

# 0.13.0 - Jun 10 2013

### Major Changes
* [mimosa #213](https://github.com/dbashford/mimosa/issues/213). Mimosa now comes with [ECO](https://github.com/sstephenson/eco) template compiling built in.  `mimosa new` also includes scaffolded ECO.
* [mimosa #187](https://github.com/dbashford/mimosa/issues/187). Mimosa is now compiled to JavaScript prior to being published to NPM. This should improve performance in a small way, but is also generally the right thing to do. The compiling of Mimosa pre-publish is performed by Mimosa.  Mimosa now has its own [mimosa-config](https://github.com/dbashford/mimosa/blob/master/mimosa-config.coffee). Mimosa has plenty of mostly CoffeeScript related lint errors that I'll be ironing out over time.

### Minor Changes
* [mimosa #212](https://github.com/dbashford/mimosa/pull/212). PR fixed issue with directories occasionally being deleted in the wrong order.  Generally effected only Windows but purely by circumstance. Theoretically should have effected all platforms.
* [mimosa #207](https://github.com/dbashford/mimosa/issues/207). Fixed validation issue with using Emblem along side other templating libraries.
* [mimosa #207](https://github.com/dbashford/mimosa/issues/207). Adjusted `mimosa-config` boilerplate comments for templates for correctness.
* mimosa. Upgraded jquery and requirejs libs in skeleton.
* mimosa. Fixed issue with Mimosa's hosted Express reporting a phantom 404 when refreshing the page.

# 0.12.6 - Jun 06 2013

### Major Changes
* [mimosa #201](https://github.com/dbashford/mimosa/issues/201), [mimosa #115](https://github.com/dbashford/mimosa/issues/115). IcedCoffeeScript boilerplate now pulled out into simple module that attaches `iced` to window. IcedCoffeeScript `runtime` compilation exposed via the `iced` config and defaults to `runtime:'none'`. You could choose, rather than going global with the `iced` object, to modify the `iced.js` library delivered with `mimosa new` to simply export `iced`, which would require you to pull in that module every time you need the async sugar IcedCoffeeScript provides.  The `mimosa new` boilerplate for IcedCoffeeScript projects shows how to use this.  But, with the `runtime` option opened up via the `iced` config, and the boilerplate code tossed into a file available via `mimosa new`, the power rests in the hands of the user to use the solution they feel is best.
* [mimosa #204](https://github.com/dbashford/mimosa/issues/204). Mimosa now allows for swapping out the version of Handlebars being used for compilation. This is useful for those building Ember apps who need versions of libraries to match. A new configuration parameter, `template.handlebars.lib`, takes the version of the handlebars compiler you'd like to use.  For example:

  ```
    template:
      handlebars:
        lib: require('handlebars')
  ```

  A project using this will need to have the desired version of Handlebars installed locally using npm.  For example: `npm install handlebars@1.0.11`.
* [mimosa #205](https://github.com/dbashford/mimosa/issues/205). Soon the `refresh` command will be removed. As of this release it has been deprecated. If you use it and rather it not go, please comment as such on this issue.

### Minor Changes
* [mimosa #202](https://github.com/dbashford/mimosa/issues/202), [mimosa #203](https://github.com/dbashford/mimosa/issues/203). Pull request fixing some CoffeeScript error reporting issues.
* mimosa. Various refactors and reorgs of codebase.

# 0.12.5 - Jun 1 2013

Back at it after a bit of a break.  Plenty to knock out in the coming weeks.

### Major Changes
* [mimosa #198](https://github.com/dbashford/mimosa/issues/198). Soon the `virgin` command will be removed. As of this release it has been deprecated. If you use it and rather it not go, please comment as such on this issue.
* [mimosa #191](https://github.com/dbashford/mimosa/issues/191). Mimosa now provides some flexibility in the naming of compiled templates. Previous to this release, templates would simply be named for the file they were in. So `foo.hbs` would be named `foo`. But certain frameworks, notably Ember, have conventions around the naming of templates that don't correspond with this, so a change we needed. A new property, `template.nameTransform` is now available for choosing how the template name is created. There are 4 possible settings.

    * (Default) `fileName`, this is the current name-of-file option. This being the default means this change is backwards compatible and won't cause any problems for folks upgrading.
    * `filePath`, this makes the name of the template the path of the file with 1) the `watch.javascriptDir` chopped off, 2) the slashes forced to `/`, and 3) the extension removed. No leading slash.
    * A RegExp can be provided.  That RegExp is applied on the `filePath` string from above to __remove__ any unwanted pieces of text from the string. The RegExp is used as part of a `string.replace`
    * A function can be provided.  That function is passed the `filePath` from above. The function must return a string that is the desired name of the template.

# 0.12.4 - May 15 2013

### Minor Changes
* mimosa. `mimosa mod:init [name] -c` now outputs a proper skeleton for a CoffeeScript based module, with all the necessary bits for using Mimosa to compile the module pre-install and publish.

# 0.12.3 - May 15 2013

### Minor Changes
* [mimosa #190](https://github.com/dbashford/mimosa/issues/190). Fixed issue with `mimosa refresh` and the previous release's `mimosa new` changes.

# 0.12.2 - May 14 2013

### Minor Changes
* mimosa. Included dust helpers in provided vendor dust file
* mimosa-require.  Bumped version of require.js to include the [newly introduced sourceMap support](http://jrburke.com/).
* Small reorg/refactor of some `mimosa new` code

# 0.12.1 - May 12 2013

### Minor Changes
* [mimosa #188](https://github.com/dbashford/mimosa/pull/188). Via pull request. `litcoffee` is now a default coffeescript extension and the coffeescript compiler will compile your Literate CoffeeScript files.
* [mimosa #186](https://github.com/dbashford/mimosa/issues/186). Can now run `mimosa mod:uninstall` without the name of the module if running command from inside the root directory of a module. So if inside `/yourMachine/modules/mimosa-foo`, running `mimosa mod:uninstall` will remove `mimosa-foo` from your Mimosa install.  This mimics the behavior of `mimosa mod:install`.
* [mimosa #184](https://github.com/dbashford/mimosa/issues/184). Fixing mimosa module creation problem.
* mimosa. Added the ability to have Mimosa exclude certain coffeescript files from sourcemap generation.  A new `sourceMapExclude` property was added that can be a regex or relative to `watch.javascriptDir`.  It defaults to `[/\/spec\//]`, which means it excludes source map generation for any files contained inside a `/spec/` directory or subdirectory.

# 0.12.0 - May 09 2013

Soon, probably with `0.13.0`, all Mimosa modules will need to be JavaScript.  They can be coded in any language you want, but they must be published to NPM as JavaScript modules.  Or, at the very least, the `main` piece of code referred to by the `package.json` [main](http://package.json.nodejitsu.com/), or the modules root level `index` file must be JavaScript.

All Mimosa modules that I have developed are written in CoffeeScript and compiled to JavaScript using Mimosa as part of the NPM workflow.  For an example Mimosa module written in CoffeeScript and built using Mimosa, check out the [require-commonjs](https://github.com/dbashford/mimosa-require-commonjs) code. You are welcome to publish modules as CoffeeScript as long as you manage that dependency.

__NOTE__ If you have trouble with your project after updating to `0.12.0`, specifically problems requiring Mimosa modules like `logmimosa`, do the following:

* Delete your `node_modules` directory
* Run `npm install` (if you have your own server)
* Start Mimosa

This should clear things up.

### Major Changes
* New module: [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple), includes `testem ci` integration.  Runs during `mimosa build` and for every JS file save during `mimosa watch`.
* All Mimosa modules are now compiled to JavaScript before publishing. Mimosa core is not, yet.
* All updated modules from previous bullet also had all their dependencies updated to the latest versions
* mimosa core has had all its libraries updated

### Minor Changes
* Upgraded dust and lodash client library to latest version
* Setting `template:null` is now a shortcut to turning off all template compilers.

# 0.11.12 - May 03 2013

### Minor Changes
* mimosa. Small refactors and fixes to module loading.
* mimosa. [mimosa #177](https://github.com/dbashford/mimosa/pull/177).  Got a pull request that allows you to code up your mimosa-config in whichever language you want, whether mimosa supports it or not.  Details in the pull request.
* [mimosa-web-package #4](https://github.com/dbashford/mimosa-web-package/issues/6). Added a new `appjs` option to `web-package`.  When set to `null`, Mimosa will not write the `app.js` application bootstrapper.  When set to a string, the string is the name `web-package` will use when writing the file.  So `appjs:"foo.js"` will write a `foo.js` file.  This setting defaults to `app.js`.
* mimosa-web-package is now compiled to JavaScript with Mimosa prior to being published to NPM.

# 0.11.11 - April 25 2013

### Minor Changes
* [mimosa #175](https://github.com/dbashford/mimosa/issues/175).  Fixed node v0.10 related issue with creating new project without a project name.
* mimosa. Updated SASS compiler to find imports that do not start with `_`.

# 0.11.10 - April 24 2013

### Minor Changes
* [mimosa #173](https://github.com/dbashford/mimosa/issues/173). You can now use external stylus libraries during compilation of Stylus files without pulling in all the source for those libraries.  A new Stylus configuration was added:

  ```
    stylus:
      use:['nib']
  ```

  Add to the `use` array those libraries you have locally `npm install`ed and want to use with Stylus.  Mimosa will get snippy with you if you try to use something that isn't installed. =)

# 0.11.9 - April 23 2013

### Major Changes
* mimosa-lint. mimosa-lint is now compiled to JavaScript prior to being published to NPM so that the delivered module is in the target language. This is the beginning of using Mimosa to compile Mimosa. I'll be cycling through all the Mimosa modules performing this change before eventually doing it with Mimosa core.
* mimosa-lint. Upgraded to latest jshint version.

### Minor Changes
* mimosa. `watch.javascriptDir` can be made `null`.  This allows for building apps that aren't strictly web apps.  Mimosa modules, for instance.
* [mimosa-web-package #4](https://github.com/dbashford/mimosa-web-package/issues/4). `web-package` will no longer write an `app.js` or execute an `npm install` if the packaged application uses the default server. (published as `web-package` version `0.10.0` on 4/18)

# 0.11.8 - April 17 2013

### Minor Changes
* [mimosa #171](https://github.com/dbashford/mimosa/issues/171). If using node 0.10 and starting mimosa in a directory with no mimosa-config, the output was a stack trace.  Now it should be a useful validation error message.
* [mimosa #172](https://github.com/dbashford/mimosa/issues/172). On Windows, `npm install` requires a `node_modules` in the current directory or else it installs the package elsewhere. So creating empty `node_modules` when needed.

# 0.11.7 - April 11 2013

### Minor Changes
* [mimosa #170](https://github.com/dbashford/mimosa/issues/170). Fixed issue with live reload crashing mimosa on node v10 + windows 8.

# 0.11.6 - April 10 2013

### Minor Changes
* [mimosa #168](https://github.com/dbashford/mimosa/issues/168). Added `md` as a default copy extension.
* [mimosa #169](https://github.com/dbashford/mimosa/issues/169). Fixing CoffeeScript compile error messages. Adding line numbers.
* [mimosa-web-package #2](https://github.com/dbashford/mimosa-web-package/issues/2). Config paths generated by `mimosa-web-package` are now target environment agnostic. Previously the paths matched the build environment.  So if you were building on Windows and deploying to *nix, there would be path work to do.  Now that is not a problem as the paths are calculated in the `config.js` that `mimosa-web-package` generates.

# 0.11.5 - April 08 2013

Doing some Heroku work, so making some changes to both Mimosa and mimosa-web-package to accommodate some Heroku learnings.

### Minor Changes
* Cleanup from previous TypeScript release
* mimosa-web-package. Added `.gitignore` to the list of files not packaged.
* mimosa-web-package. The output `config.json` which was a partially resolved `mimosa-config`, is now `config.js` as it contains some code. That code helps properly point the packaged web app at the location of the compiled assets. For instance, Heroku isn't happy with "public", it needs to be pointed at `path.join(__dirname, "public")`.
* mimosa. Modified `mimosa new` delivered servers to set port in a way that makes Heroku happy.
* [mimosa #165](https://github.com/dbashford/mimosa/issues/165). Fixed issue with Mimosa new erroring out.

### Breaking Changes
* Only possible breaking changes are minor and with `web-package`, and in most cases shouldn't be breaking at all.  Previously the `web-package` config file was output as `config.json`, now it is `config.js` as it contains some code to resolve the location of static assets properly.

# 0.11.4 - April 07 2013

### Major Changes
* Got a great pull request that upgraded TypeScript support to `0.8.3.0` and fixed some other TypeScript issues.

# 0.11.3 - April 04 2013

Purely a `mimosa-require` related release. Enhanced requirejs/r.js support in many ways.

### Major Changes
* [mimosa-require #9](https://github.com/dbashford/mimosa-require/issues/9) - Mimosa's requirejs support now includes recognition of common configuration. Now for multi-page applications, you can create a single requirejs configuration that gets referenced by your main modules. This support extends to the use of `r.js` and to Mimosa's requirejs path validation.

  By default, Mimosa will look in `javascripts/common.js` for common config. For a good example of how a common require config works, check out the [the requirejs example](https://github.com/requirejs/example-multipage/tree/master/www/js) for that sort of project.  Pay special attention to the `common.js` file and how it is included and used in `page1/2.js`

### Minor Changes
* mimosa-require. Added detection of `require` calls embedded within the callbacks of other `require` calls.  Previous only `define` callbacks were scanned for `require` calls.
* mimosa-require. Added detection of `require` calls that take arrays of dependencies that are embedded within other `define`/`require` callbacks. Previously only single string `require` calls (i.e. `require('foo')`) were detected.  Now requires with arrays and callbacks are detected.  i.e. `require(['foo', 'bar'], function(){})`
* mimosa-require. Fixed issue with path validations caching references to aliased directories.

# 0.11.2 - March 28 2013

Various lib updates.

### Minor Changes
* Upgraded the `require.js` and `jquery.js` delivered with `mimosa new`
* Upgraded the `package.json` delivered with `mimosa new`
* `mimosa new` will now output the `npm install` output on successful install.
* Mimosa's auto-install of Mimosa modules on startup will now output the `npm install` output on successful install.
* npm updated to latest

# 0.11.1 - March 24 2013

### Minor Changes
* [mimosa-server #3](https://github.com/dbashford/mimosa-server/issues/3) - When not using the default server (when project has its own server), the config setting `server.views.path` is relative to `server.path` instead of relative to the root of the project. When using the default server `server.views.path` remains relative to the root of the project. The `server.views.path` is passed to the project's server.

### Possible Breaking Changes
* If you've got your own server and have configured specific (non-default) paths for `server.views.path` and `server.path`, you may need to tweak the `server.views.path`.

# 0.11.0 - March 21 2013

Source maps! Part of the changes for adding source maps opened up being able to configure the coffeescript compiler from the `mimosa-config`, so defaulting `bare` compilation to `true`, which has been a rainy day thing I've wanted to do for awhile, became possible. That might break some applications that aren't wrapping code (if you aren't using AMD or CommonJS via AMD), hence the uptick to `0.11.0`. See the Breaking Changes section below.

### Major Changes
* mimosa #163. CoffeeScript and Iced CoffeeScript files will now compile `bare` by default. The assumption is that with Mimosa being opinionated towards the use of AMD or AMD wrapping of CommonJS modules, all code ought to be wrapped anyway. This can be set back with config. See the config snippet below.
* mimosa #161. CoffeeScript [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) ftw. Source maps are enabled by default for CoffeeScript files for `mimosa watch`.  A new `coffeescript` root level config allows for turning source maps off. Source maps are turned off during `mimosa build`. If you've not used source maps before, I highly encourage trying them out. Quickly fire up a new Mimosa project, `mimosa new foo -d`, and break some CoffeeScript. Then point at the project with Chrome developer tools on and bear witness to the source map goodness.

  ```coffeescript
    coffeescript:
      sourceMap:true
      bare:true
    iced:
      bare:true
  ```

### Minor Changes
* mimosa #162. Added `map` to the list of default copy extensions.

### Possible Breaking Changes
* With `bare` now set to `true` by default (was previously `false`), you'll want to check your Coffee/Iced apps to make sure things still work alright. If they don't simply flip the setting back to `false` or address why unwrapped code and scope bleed might be causing trouble.

# 0.10.6 - March 16 2013

### Minor Changes
* mimosa #160.  Log error if `mimosa new` `npm install` fails.

# 0.10.5 - March 16 2013

### Minor Changes
* mimosa #159.  First and hopefully last node `v0.10.0` bug fix.

# 0.10.4 - March 15 2013

### Major Changes
* mimosa #146.  First new module in awhile.  [mimosa-client-jade-static](https://github.com/dbashford/mimosa-client-jade-static) will take files that end in `.html.jade`, static jade templates, compile them, execute them, and write them as individual `.html` files. These jade templates cannot be dynamic in any way. The (initial) target use case is to have small template files to pull in using RequireJSs `text` plugin.
* mimosa #138.  New mimosa-combine version defaults to removing the files that go into the combined file during `mimosa build` (not during `mimosa watch`).  This deprecates the old config.  For one minor version mimosa-combine will support both the old and new configs for mimosa-combine and will warn you when Mimosa starts to give you the change to make the necessary changes.  The deprecated config option will be removed the next time mimosa-combine has a significant release.  See the [mimosa-combine github](https://github.com/dbashford/mimosa-combine) for config details.
* mimosa-require #10. Default support for requirejs source maps has been added. When `mimosa watch` is used with `--optimize` (and not also `--minify` which does minification outside of requirejs), Mimosa will generate source maps for easy debugging in browser dev tools. `mimosa build` does not generate source maps. All cleans performed by various Mimosa tasks will clean up the generated `.src` and `.map` files.  Because generation of source maps is configured via the r.js config, which can already be overridden in the `require` config, no additional config settings have been added to change the default behaviors.

### Minor Changes
* mimosa #157. Fixed issue with css pre-compilers thinking directories were files.
* mimosa #155. Fixed issue with new `mimosa-client-jade-static` module that wasn't letting modules update/delete after startup.
* mimosa #154. Non JS will not get sent through require path verification, not a problem previously but will be a problem with any modules that turn what is typically a fully JS workflow (like template compiling) into a mixed workflow (like when jade templates are compiled to static HTML on the server as with mimosa-client-static-jade)
* mimosa #152. Extension-to-compiler matching is now case-insensitive. So as far as Mimosa is concerned, PNG == png, and so on.
* mimosa #150. Improved default server error messaging when a view is not found.
* mimosa-require. Removed dependency on uglify.
* mimosa-require. `uglify2` is now the default Uglifier for RequireJS. If needed this can be changed back to `uglify` by overriding the optimizer settings in the `require` config.
* mimosa-server-reload #3, improved error messaging for module not being in the same module space as other mimosa modules it depends on.

# 0.10.3 - March 3 2013

### Major Changes
* Fixes #147, with the help of the Emblem author, refactored the Mimosa Emblem compiler to not depend on jsdom, which introduces some cross-platform issues.
* Upgraded to the latest Emblem which also removes a Mimosa dependency on git introduced in the last release.

# 0.10.2 - Feb 25 2013

### Major Changes
* Auto-installed modules, those discovered in the `modules` array but not discovered installed in any of Mimosa's module scopes, will now install into the project scope. This should alleviate permissions issues with installing modules into Mimosa which is often installed in a global protected scope.

# 0.10.1 - Feb 25 2013

### Major Changes
* mimosa #145, added [Emblem](http://emblemjs.com/) compiler. Emblem is wicked cool. Despite resembling jade/haml,it parses to [Handlebars](http://handlebarsjs.com/) [AST](http://en.wikipedia.org/wiki/Abstract_syntax_tree) which can then be passed to Handlebars for precompilation. The output of precompilation is the same as the output for pure Handlebars precompilation. This is awesome for folks that need to use Handlebars (Ember.js) but prefer a terser syntax.

  The existing `template.handlebars` config is used by the Emblem compiler.  The Emblem compiler can output Ember compliant code by enabling ember the same way as with handlebars. So the snippet below from the `0.10.0` release applies to Emblem.  See the [Mimosa Ember Emblem project on github](https://github.com/dbashford/mimosa-ember-emblem-templates) for an example of this running.

# 0.10.0 - Feb 23 2013

Jumping up to `0.10.0` as there are a few breaking changes, so check out the "You'll need to..." section below.

Updates to how templating is handled has been a theme, and this release continues that. Added Ember.Handlebars and the ability to skip the AMD wrapping of compiled templates. Also added more robust routing capabilities to the default server.

### Major Changes
* mimosa #135, Mimosa's handlebars template compiler will now compile Ember.js templates. To enable Ember compiling, inside the `template.handlebars` config, place an `ember` object like so:

  ```
    template:
      handlebars:
        ember:
          enabled:true
          path:"vendor/ember"
  ```

  The `enabled` flag turns on Ember compiling, and the path string is the AMD location of the Ember library, which is built into the AMD wrapper for the compiled templates.
* mimosa #140, Mimosa's template compilers will now allow combined/merged template file compilation without the AMD wrapper.  A new property `amdWrap` has been added to the `template` config.  It defaults to `true`.  When set to `false`, Mimosa will not AMD wrap the compiled template files.
* mimosa #144, Mimosa's default server got a bit of an overhaul.  The `server.useDefaultServer` property is now `server.defaultServer.enabled` to make way for more `defaultServer` config.  Added to `defaultServer` is a `onePager` boolean that defaults to `false`. When set to `true` Mimosa will route all traffic through the `index` view. This allows for complex URLs like `url:3000/user/steve` to route to the `index` view and then be handled by client routing code. When `onePager` is set to `false`, Mimosa will route all traffic to assumed view names. `url:3000/` will go to `index` as expected, but now `url:3000/foo` will go to `foo` and so on.

### Minor Changes
* mimosa, fixed template name collision issue
* If a project scoped Mimosa module errors out upon requiring, Mimosa now exits.
* mimosa #133, complex folder structures for stylesheets no longer causing issues with proper stylesheets being compiled
* mimosa #137, handling file extensions properly in mimosa-require for dependencies aliased by directory
* mimosa #142, moved `helperFiles:[]` into `handlebars:helpers:[]` to make way for more template specific config.
* mimosa #143, update client and server handlebars to latest version
* mimosa-web-package, with `0.9.0` Mimosa modules can be in a project's package.json. Now Mimosa module dependencies are removed from the package.json before it is written into the `dist` directory.
* mimosa-require-commonjs #2, fixed issue with empty output from .d.ts files
* mimosa-require-commonjs #3, fixed issue with excludes not working properly

### You'll need to...
* If you were using the `helperFiles` config, you'll need to change that config around.  `helperFiles:[]` should now look like this:

  ```coffeescript
    handlebars:
      helpers:[]
  ```

* `server.useDefaultServer` is now `server.defaultServer.enabled`.  Also added is a `server.defaultServer.onePager` boolean which defaults to `false`. If you were relying on Mimosa's default server to route all paths through the index page, then you will want to set `onePager` to `true`. The default for this was essentially `true` prior to this release.

  ```coffeescript
    server:
      defaultServer:
        enabled: true
        onePager: true
  ```

# 0.9.0 - Feb 12 2013

Big release with three big new features.  Also a few minor breaking changes, so definitely check those out.  I've got a few high priority bugs I need to address after this release, but I expect the next large priority is to build a testing module.

### Major Changes
* mimosa #125, Mimosa will now allow you to take multiple folders worth of micro-templates and bundle them together into separate compiled and merged template files.  So, for example, if you've got two pages, `search` and `user`, which each have many templates of their own (inside `search` and `user` directories), but that also share common templates from a `shared` folder you can now configure that like so:

  ```
    template:
      output: [{
        folders:["search","shared"]
        outputFileName: "search_templates"
      },
      {
        folders:["user","shared"]
        outputFileName: "user_templates"
      }]
  ```

  This will result in two template files being created, one for each page, each containing the page specific templates and those from the shared directory.

  Note that the former `outputFiles` property, introduced a few releases ago, has changed to `output`, and `folder` is now `folders` and is an array as opposed to a string.  `folders` is relative to the `watch.javascriptDir` setting, and can be any number of folders.

* mimosa #122, Mimosa now supports profile loading at startup for the `watch`, `build`, `clean` and `virgin` commands.  Those commands have a new `-P/--profile` flag that takes a string.  That string is the name of a Mimosa config file in a `profiles/` folder in the root of the project.  Profile files are simply `mimosa-config` files that override the main project `mimosa-config`.

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
* Mimosa no longer checks every template that comprises a compiled and merged template file to determine if the template needs to be compiled.  Mimosa just performs the compilation for templates no matter what.  Previously, on startup, Mimosa would check every template file to see if it needed to compile the templates.  That was wasteful and a bit more complicated than it needed to be.  If someone clamors for it I can return to check it out, but I expect it won't be missed.

### You'll need to...
* If you were using the recently introduced `outputFiles` config, the name is now simply `output`.  And the `folder` configuration is now `folders` and is an array instead of a string.

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