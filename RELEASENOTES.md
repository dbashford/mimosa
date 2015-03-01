## 3.0.0 - April ? 2015

Work towards a `3.0.0` in under way. Looking for across the board library updates, a large test bed, a conversion of the codebase to JavaScript among many other changes.  Keep eyes peeled here as any updates will get added to this list.

As updates to external modules are listed here, know that you can use them right away by updating your `mimosa-config`.  For instance to use the latest bower (`1.8.1` as of this writing), updating your `modules` array to point to `bower@1.8.1`.

### Possible Breaking Changes
* [mimosa #425](https://github.com/dbashford/mimosa/issues/425). Support for non-inline source maps has been removed from mimosa-core. Mimosa's JavaScript compilers will no longer create `.map` and `.src` files.  All JavaScript source maps will be inlined as support for inline source maps is wide. Additionally conditional source map comments, `//#`, are no longer allowed.
* [mimosa-server](https://github.com/dbashford/mimosa-server) has had its `packageJSONDir` property removed and the requirement of a `package.json` eliminated. A new property, `transpiler`, has been added. If you are using, for instance, CoffeeScript on the server, then you will want to set the `transpiler` property to the `require`d transpiler library. Ex: `transpiler: require('coffee-script')`

### Major Changes
* __New Module__ [mimosa-phantomcss](https://github.com/dbazile/mimosa-phantomcss) will run visual testing using [PhantomCSS](https://github.com/Huddle/PhantomCSS) and Casper.
* __New Module__ [mimosa-babel](https://github.com/YoloDev/mimosa-babel) is a new JavaScript compiler that wraps the [babel](https://babeljs.io/) (formerly 6to5) transpiler. babel turns your ES6 JavaScript to ES5 JavaScript.
* __New Module__ [mimosa-npm-web-dependencies](https://github.com/dbashford/mimosa-npm-web-dependencies) will let you install NPM dependencies into your web app, and if that dependency has a big dependency tree, it will use browserify to bundle the dependency before injecting it.
* __New Module__ [mimosa-hogan-static](https://github.com/dbashford/mimosa-hogan-static) will compile hogan templates into individual `.html` files. This module gives you the means to provide your hogan templates with a variable context, a list of partials, and a list of global settings to use across all of your templates.
* __New Module__ [mimosa-rename](https://github.com/dbashford/mimosa-rename) allows you to rename files before they are written.
* __New Module__ [mimosa-twig](https://github.com/dbashford/mimosa-twig) supports twig as a client side templating library.
* [mimosa #428](https://github.com/dbashford/mimosa/issues/428) removed the `mimosa config` command, which also removes the `mimosa-config-documented.coffee` file that `mimosa config` and `mimosa new` (via `mimosa config`) would write. Thus continues the simplification of the tool. If its not bolted down...
* [mimosa-bower #44](https://github.com/dbashford/mimosa-bower/issues/44). You can now use a regex to match packages to a `strategy`:
  ```javascript
    strategy: {
      "/^jquery/": "vendorRoot"
    }
  ```
* [mimosa-bower #40](https://github.com/dbashford/mimosa-bower/issues/40). This adds a new `together` strategy that allows for keeping js/css assets together inside a specific directory.  Also added was a `togetherRoot` path where those packages with a `together` strategy are placed.  `togetherRoot` is `components` by default.  For an example, check out the [polymer demo app](https://github.com/brzpegasus/mimosa-polymer-demo) which keeps all of the polymer components (and their `.html`, `.css` and `.js`) inside the `components` folder.
* [mimosa-require #42](https://github.com/dbashford/mimosa-require/issues/42). Addressed an issue which was preventing re-bundling/optimizing of applications during `mimosa watch`. Should now again be able to run `mimosa watch -o`, change files, and have the act of changing files re-run r.js and re-optimize your app.
* [mimosa-minify-js](https://github.com/dbashford/mimosa-minify-js) no longer supports writing `.map` files. Starting with version `v2.0.0` of that module (released), all source maps will be inline base64 encoded maps.
* [mimosa-minify-js](https://github.com/dbashford/mimosa-minify-js) will now find any embedded inline base64 encoded source maps and use them as input to minification so that you can have multi-stage source maps. This allows source maps to go from minified js back to JavaScript and back to whatever your code may have been before it was JavaScript, like CoffeeScript or es6 flavored JavaScript.
* [newmimosa](https://github.com/dbashford/newmimosa). `mimosa new` now delivers the latest of all its assets.  This includes a big update to Hapi `0.8.1` as well as some fixes for nunjucks apps.
* [newmimosa](https://github.com/dbashford/newmimosa). `mimosa new` no longer makes recommendations.  It also no longer supports the `--defaults/-d` flag.
* [newmimosa](https://github.com/dbashford/newmimosa). Cleaned up some bad boilerplate code and incorporated Twig templates.
* [newmimosa](https://github.com/dbashford/newmimosa). Now will insert the new `transpiler` property into the mimosa-server config in the mimosa-config if a transpiled language is chosen.
* [newmimosa](https://github.com/dbashford/newmimosa). A `mimosa-config-documented.coffee` will no longer be generated when you create a `mimosa new` project.


### Minor Changes
* [mimosa #427](https://github.com/dbashford/mimosa/issues/427). mimosa core's base JavaScript compiler can now handle both object and string source maps.
* [mimosa #426](https://github.com/dbashford/mimosa/issues/426). mimosa core's base JavaScript compiler will now recognize if an inline source map is in place before adding a new one.
* [mimosa-minify-css](https://github.com/dbashford/mimosa-minify-css) has been updated to the latest version of [clean-css](https://github.com/jakubpawlowicz/clean-css)
* [mimosa-live-reload #6](https://github.com/dbashford/mimosa-live-reload/pull/6). Fixed a small bug with script finding.
* [mimosa-live-reload #7](https://github.com/dbashford/mimosa-live-reload/issues/7). Readdressed the hack for getting Chrome to repaint CSS updates whether or not it has focus.
* [mimosa-live-reload](https://github.com/dbashford/mimosa-live-reload). Updated to latest and updated socket.io.
* [mimosa-copy #1](https://github.com/dbashford/mimosa-copy/issues/1). Added `.swf` to default copy extensions.
* [mimosa-copy #3](https://github.com/dbashford/mimosa-copy/pull/3) added `woff2` to default copy extensions.
* [mimosa-csslint #4](https://github.com/dbashford/mimosa-csslint/issues/4). Now properly recognizes vendor files on startup.
* [mimosa-csslint](https://github.com/dbashford/mimosa-csslint/). Updated to latest csslint.
* [mimosa-jshint](https://github.com/dbashford/mimosa-jshint/). Updated to latest jshint.
* [mimosa-typescript](https://github.com/dbashford/mimosa-typescript/). Pinned typescript versions to fix compilation issues.
* [mimosa-coffeescript](https://github.com/dbashford/mimosa-coffeescript/), [mimosa-iced-coffeescript](https://github.com/dbashford/mimosa-iced-coffeescript/), and [mimosa-livescript](https://github.com/dbashford/mimosa-livescript/) have been updated to the latest compiler versions.
* [mimosa-less](https://github.com/dbashford/mimosa-less/) has been updated to the latest less.
* [mimosa-less](https://github.com/dbashford/mimosa-less/) had issues with inline source maps addressed.
* [mimosa-react #1](https://github.com/dbashford/mimosa-react/pull/1) addressed a bug involving empty output.
* [mimosa-react #2](https://github.com/dbashford/mimosa-react/pull/2) removed the JSX pragma from compiled JSX files.
* [mimosa-ember-module-import #3](https://github.com/dbashford/mimosa-ember-module-import/issues/3) normalizes paths written to the file system in the cache to unix style. This prevents cache diffs when teams working on a project are using both Windows and nix.
* [mimosa-sass #7](https://github.com/dbashford/mimosa-sass/issues/7). Added support for node-sass `2.0`.
* [mimosa-bower #47](https://github.com/dbashford/mimosa-bower/issues/47). Normalize paths in last
 installed file so that they do not cause diffs between OSs.
* [mimosa-require #45](https://github.com/dbashford/mimosa-require/issues/45) added a `removeCombined` flag that will allow you to turn off the removal of combined/concatenated assets during build.  Will default to `true`.

## 2.3.31 - February 11 2014

### Minor Changes
* [mimosa #433](https://github.com/dbashford/mimosa/issues/433) removes the `customFds` deprecation warning on startup for node `v0.12.0`.

## 2.3.30 - January 30 2014

### Minor Changes
* [skelmimosa #31](https://github.com/dbashford/skelmimosa/issues/31). `mimosa skel:new` will now run a `npm install` inside the created project.

## 2.3.29 - January 27 2014

### Minor Changes
* [mimosa #429](https://github.com/dbashford/mimosa/issues/429). If no files in source directory, user is warned and workflows continue, previously processing would hang.

## 2.3.28 - January 22 2014

### Minor Changes
* More work with mimosa-live-reload to get CSS reloading to work properly in Chrome.

## 2.3.27 - January 22 2014

### Minor Changes
* Adjusted how source map comments are included in transpiled JavaScript files.

## 2.3.26 - January 12 2014

### Minor Changes
* [mimosa #422](https://github.com/dbashford/mimosa/issues/422). Now calls to `logger.fatal` will automatically exit with non-0 status code.

## 2.3.25 - December 30 2014

### Minor Changes
* Using `util.inspect` to avoid circular logging issues.

## 2.3.24 - December 19 2014

### Major Changes
* [mimosa-combine #19](https://github.com/dbashford/mimosa-combine/issues/19). mimosa-combine now includes, by default, source maps for the files it combines. These source maps will not incorporate existing source maps, and they will not factor in any changes made by transform functions.

### Minor Changes
* [mimosa #420](https://github.com/dbashford/mimosa/issues/420). Handle circular references among CSS imports.
* [mimosa-combine #21](https://github.com/dbashford/mimosa-combine/issues/21). Since they are not used, existing source maps are removed from combined files before they are combined.

## 2.3.23 - December 15 2014

### Minor Changes
* [mimosa-jscs](https://github.com/al-broco/mimosa-jscs) continues to improve, adding support for `maxErrors`, `additionalRules`, and `esnext`
* [mimosa-combine #14](https://github.com/dbashford/mimosa-combine/issues/14). Added an `include` option that allows you to pick and choose specific files to be included.  This lets you pick a few to include from a large group of files in a folder rather than have to `exclude` a large list.
* [mimosa-combine](https://github.com/dbashford/mimosa-combine). Addressed issue involving `removeCombined` and multiple folder entries.
* [mimosa-combine #15](https://github.com/dbashford/mimosa-combine/issues/15). Fixed an issue with binary files being removed unexpectedly.
* [mimosa-combine #16](https://github.com/dbashford/mimosa-combine/issues/16). Added ability to provide custom transforms that can modify files being transformed before they are combined.  [Details here](https://github.com/dbashford/mimosa-combine#transform-functions).
* [mimosa #418, mimosa-restart](https://github.com/dbashford/mimosa/issues/418). [mimosa-restart](https://github.com/dbashford/mimosa-restart) has been updated to allow for configurable restart paths and to allow for mimosa to be restarted when things are both removed and updated. The [example config](https://github.com/dbashford/mimosa-restart#example-configuration) has a really good example of how this would be used, which includes restarting mimosa when the `mimosa-config` is updated.

## 2.3.22 - December 10 2014

### Major Changes
* __New Module__: [mimosa-ember-env](https://github.com/dbashford/mimosa-ember-env) will include `EmberENV` setup calls at the top of your ember.js vendor libs.
* __New Skeleton__: [MimosaEmberHTMLBars](https://github.com/dbashford/MimosaEmberHTMLBarsSkeleton). The Cadillac of Ember + Mimosa skeletons. Includes support for HTMLBars, QUnit/Testem, automatical Ember module manifest generation, EmberENV inclusion, as well as all the other features that come with most Mimosa apps: live reload, server support, Bower integration, ES6 module transpiling, SASS compiling (via node or Ruby), a all sorts of minification/concatenation/optimization.

### Minor Changes
* Updated validations to add excludes and allow includes to behave like excludes.

## 2.3.21 - December 4 2014

### Minor Changes
* * __New Module__: [mimosa-jscs](https://github.com/al-broco/mimosa-jscs) wraps the popular [JSCS](https://github.com/jscs-dev/node-jscs) tool which performs JavaScript style checking.
* [esperanto-es6-modules](https://github.com/dbashford/mimosa-esperanto-es6-modules). Updated to latest esperanto (options changed, so check it out before upgrading) which includes support for source maps.
* [mimosa-require #41](https://github.com/dbashford/mimosa-require/issues/41). Shims and shim depedencies will now have their paths checked against directory aliases.

## 2.3.20 - November 19 2014

### Minor Changes
* Bumped mimosa-live-reload to latest socket.io to bypass some installation issues.
* [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple). Adjusted to handle when configFile is not array (as with testem-require).
* [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require). Bumped to latest testem-simple.

## 2.3.19 - October 26 2014

### Major Changes
* [mimosa-sass](https://github.com/dbashford/mimosa-sass) now includes inline (dynamic) source maps for node compiled SASS.

### Minor Changes
* [mimosa-handlebars](https://github.com/dbashford/mimosa-handlebars). Pushed Handlebars to 2.0.
* [mimosa #414](https://github.com/dbashford/mimosa/issues/414). Fixed lingering commonjs flag from recent mimosa-require parsing refactor.

## 2.3.18 - October 13 2014

### Minor Changes
* [mimosa-livescript #1](https://github.com/dbashford/mimosa-livescript/pull/1). Pushing to latest LiveScript.
* [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple). Forcing testem tests to exit during build when `-e` flag is ticked.
* [mimosa-ember-test](https://github.com/dbashford/mimosa-ember-test). Bumped to latest testem-simple.
* [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require). Bumped to latest testem-simple.
* [mimosa-server](https://github.com/dbashford/mimosa-server). Default server now sending pretty printed jade during dev. [See discussion](https://groups.google.com/forum/#!topic/mimosajs/BHeTf728lbQ)

## 2.3.17 - September 24 2014

### Minor Changes
* [mimosa-minify-css #1](https://github.com/dbashford/mimosa-minify-css/issues/1). Catching if text for file is null.

## 2.3.16 - September 23 2014

### Major Changes
* __New Module__: [mimosa-esperanto-es6-modules](https://github.com/dbashford/mimosa-esperanto-es6-modules). Transpiles es6 module syntax to es5 commonjs/amd. [esperanto](https://github.com/Rich-Harris/esperanto) is a faster more straight forward alternative to the es6-module-transpiler.  It is for now a little less flexible, but if you do not have a mix of named and default exports in your application it is 100% worth making the switch to use esperanto.
* [mimosa-require #40](https://github.com/dbashford/mimosa-require/issues/40). Files with nested `require('')` and `require([],function(){})` calls should no longer be flagged as main modules.

### Minor Changes
* Updated [mimosa-minify-css](https://github.com/dbashford/mimosa-minify-css) to latest version of clean-css, also fixed small syntax error in coffeescript doc output.

## 2.3.15 - September 14 2014

### Minor Changes
* [mimosa-ember-module-import #2](https://github.com/dbashford/mimosa-ember-module-import/issues/2). Fixes ember-module-import on Windows.
* [mimosa-bower #42](https://github.com/dbashford/mimosa-bower/issues/42). Fixed issue with `exclude` paths and Windows.

## 2.3.14 - September 14 2014

### Minor Changes
* [mimosa-require](https://github.com/dbashford/mimosa-require) had a small change to when it ran its code in mimosa's workflows to allow for other modules to get their tasks done before mimosa-require runs validation.

## 2.3.12/2.3.13 - September 11 2014

### Major Changes
* __Upgraded Module__: [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple) has received some upgrades. It is now written in JavaScript. It now has a suite of tests for most of its functionality. The messaging as been improved slightly. And you can now pass multiple `testemConfig` files if you have multiple test harnesses.

### Minor Changes
* Updated validators so that when an property is set to `false` it isn't considered not being there.

## 2.3.11 - September 9 2014

### Minor Changes
* Updated validators so that `isObject` no longer accepts `null` and the validations that expect things to exist don't just check `null`.

### Major Changes
* __New Module__: [mimosa-defeature](https://github.com/peluja1012/mimosa-defeature) will slice flagged features out of an application at build time. Effects CSS, JavaScript and templates. Use this to hide features that aren't quite ready, or to remove features from a product that a client doesn't need or hasn't paid for.
* __New Module__: [mimosa-minify-json](https://github.com/dbashford/mimosa-minify-json) will.. minify JSON! As with all minification modules, minification occurs when the `-m/--minify` flag is ticked.
* __Upgraded Module__:[mimosa-require](https://github.com/dbashford/mimosa-require) has been updated to use the latest require.js, but Mimosa core has not been updated to use the latest mimosa-require.  [Read more about why.](http://dbashford.github.io/bumping-require-js-but-not-for-mimosa-yet/index.html)

## 2.3.9/2.3.10 - September 1 2014

### Minor Changes
* Updated validatemimosa so that modules have utility methods for checking RegExp and boolean
* Addressed timing issues with [mimosa-server-reload](https://github.com/dbashford/mimosa-server-reload) that caused the reload to fire at the end of startup.

## 2.3.8 - August 28 2014

### Major Changes
* __New Skeleton__: [MimosaTypeScript](https://github.com/dbashford/MimosaTypeScript). The first TypeScript skeleton! This includes the new improved typescript compiler support (see next bullet) but also includes a Hapi server, Less for CSS pre-processing, and dust for templates.
* [mimosa-typescript #1](https://github.com/dbashford/mimosa-typescript/issues/1). Major upgrade in TypeScript support.  Adds source maps, adds ability to exclude `.d.ts` files from compilation.  Upgrades typescript library itself to latest.

### Minor Changes
* To support some work for the typescript compiler, added `isVendor` flag to file object prior to calling javascript module `compile` functions.

## 2.3.6/2.3.7 - August 23 2014

### Minor Changes
* [mimosa-bower #41](https://github.com/dbashford/mimosa-bower/pull/41). Fixed issue with `mimosa bower:install` command.

### Major Chnges
* __New Skeleton__: [Durandal-Foundation-NoAlmond] (https://github.com/DrSammyD/Durandal-Foundation-No-Almond-Mimosa-Skeleton). A Durandal skeleton project with a ton of integrated libraries, working optimization, an Express server with Handlebars server views, and Bower integration.

## 2.3.5 - August 21 2014

### Minor Changes
* [mimosa #407](https://github.com/dbashford/mimosa/issues/407). Addressing issues with an empty `.mimosa_profile`.

## 2.3.4 - August 21 2014

### Minor Changes
* Fixed small bug in validators noticed after pulling them out of mimosa.

## 2.3.3 - August 21 2014

### Minor Changes
* To ease testing of modules, Mimosa's configuration validation code has been pulled out and placed in a separate NPM module: [validatemimosa](https://github.com/dbashford/validatemimosa). Mimosa now includes this library.  But now Mimosa modules can include this library as a testing dependency to test and validation routines it runs through.

## 2.3.2 - August 20 2014

### Major Changes
* __New Module__: [mimosa-ember-module-import](https://github.com/dretay/mimosa-ember-module-import) will use some conventions to build out a complete set `require` definitions for all your Ember related code. See the GH for details.
* __New Module__: [mimosa-start-server](https://github.com/dbashford/mimosa-start-server) will start your server at the appropriate time. No need to return a server object.  Conitnue using [mimosa-server](https://github.com/dbashford/mimosa-server) if you are using the default server or need anything like live reload or server reload.
* __New Skeleton__: [MimosaEmberSkeleton](https://github.com/dbashford/MimosaEmberSkeleton) uses the new [ember-module-import](https://github.com/dretay/mimosa-ember-module-import) is a port of the Ember Blogger example. Uses ES6 modules, automatic ember manifest generation, SASS, Express and comes ready to optimize and bundle. This skeleton is loaded and ready to go.  Testing support for Ember coming soon!
* [mimosa #406](https://github.com/dbashford/mimosa/issues/406). New with this release is the introduction of default profiles. Profiles are a powerful and popular feature. Using a profile is easy enough, `mimosa build -P <<profile name>>`, and recent releases have allowed you to chain together multiple profiles, `mimosa build -P profile1#profile2#profile3`.  But if you have a set of profiles that you are constantly applying, you find yourself typing `-P <<profile name>>` quite a bit.  Now you can keep a default profile in a `.mimosa_profile` file at the root of your project.  This file, a `\n`-delimited list of profile names, will be the first profiles applied.  You can also append `-P <<profileName>>` and those profiles will be applied last (and therefore override any settings in a default profile).

## 2.3.1 - August 13 2014

### Minor Changes
* [mimosa-require #39](https://github.com/dbashford/mimosa-require/issues/39). mimosa-require will no longer turn off a forced recompile if another module has chosen to force one.

## 2.3.0 - August 12 2014

### Huge Changes
* `mimosa new` has been updated to include a new server option: [Hapi](http://hapijs.com/). Now with `mimosa new` you can get a Hapi project ready to go with one of the templating options (Jade, Handlebars, Hogan, Dust, EJS, HTML).
* `mimosa new` has been updated to include a new server option: Express w/socket.io. This delivers the same Express skeleton, except with socket.io already included.

### Major Changes
* __New Module__: [mimosa-rpm-package](https://github.com/dretay/mimosa-rpm-package) works much like the popular web-package module, but uses [easy-rpm](https://github.com/panitw/easy-rpm) to create an RPM archive of an application.
* __New Skeleton__: [hapi-angular-browserify](https://github.com/rclayton/mimosa-browserify-hapi-angular). An Angular app served up via Hapi and bundled with browserify.  Is coded in CoffeeScript.
* `mimosa new` has been updated to deliver the latest Express: `4.7.2`
* [mimosa-live-reload](https://github.com/dbashford/mimosa-live-reload) has been updated to solve a recent issue with updating CSS in Chrome. Previously CSS would not update in Chrome until Chrome received focus.  So if you were in your text editor and made a change, you'd have to hover over Chrome to see the change take effect.  This is fixed.  The solution is slightly hacky but the result is what you'd expect, the CSS is re-evaluated whether focus is given or not.  It solves the problem by first breaking the URL of the stylesheet before fixing it.  This is transparent while staring at the UI, but if looking at the network pane, you'll see a red line where the UI attempted to bring in a file that did not exist. This will just have to be documented, understood and ignored.  This behavior will only take place in Chrome.  All other browsers will continue to work the same way.

### Minor Changes
* All of the libraries delivered by `mimosa new` are updated to the latest version.
* Addressed timing issues with [mimosa-server-reload](https://github.com/dbashford/mimosa-server-reload). Now server should not be restarted until the previous instance has been fully closed out.
* [mimosa-minify-js](https://github.com/dbashford/mimosa-minify-js/pull/2) added a `mangleNames` property to the minifyJS config. It defaults to `true`, which leaves current functionality intact but when set to `false` variable names will not be altered.
* [mimosa-server](https://github.com/dbashford/mimosa-server) had all its built-in template compilers updated to the latest.

## 2.2.21 - August 6 2014

### Minor Changes
* Removed leftover logs from sync debugging.

## 2.2.20 - August 1 2014

### Major Changes
* [mimosa-require](https://github.com/dbashford/mimosa-require) had a small (1-line) update that resulted in big performance improvements for large requirejs based applications.  Some of the developers on my team (without SSDs) saw the speed of their build cut in half.  I highly recommend you check it out. I'd love to get some `time mimosa build` diffs from folks upgrading to `2.2.20`.

### Minor Changes
* [mimosa-csslint](https://github.com/dbashford/mimosa-csslint) now runs `beforeWrite` which allows any transforms to occur to css prior to being linted. For instance, if using the autoprefixer module, this allows for vendor prefixes to be applied before running CSSLint.
* [mimosa-just-copy #3](https://github.com/dbashford/mimosa-just-copy/pull/3). Previously just-copy was only capable of "just copying" files to the output location Mimosa would have otherwise copied the file. A great PR added the ability to specify an entirely different output location for input files.  See the docs for details.
* [mimosa-handlebars #1](https://github.com/dbashford/mimosa-handlebars/issues/1), fixed the client library, making it the same version as the compiler.
* [mimosa-emblem](https://github.com/dbashford/mimosa-emblem/), fixed client library bug.

## 2.2.19 - July 28 2014

### Major Changes
* __New Module__: [mimosa-fix-rjs-ember](https://github.com/dbashford/mimosa-fix-rjs-ember). Addresses issues with r.js optimization + ember.js beta/canary builds

### Minor Changes
* Updated [mimosa-ractive](https://github.com/dbashford/mimosa-ractive) to latest compiler and client library.
* Updated [mimosa-hogan](https://github.com/dbashford/mimosa-hogan) to latest compiler and client library.
* Updated [mimosa-dust](https://github.com/dbashford/mimosa-dust) to latest compiler and client library.
* Updated [mimosa-jshint](https://github.com/dbashford/mimosa-jshint) to latest version of jshint
* Updated [mimosa-stylus](https://github.com/dbashford/mimosa-stylus) to latest version of stylus and nib.
* Updated [mimosa-react](https://github.com/dbashford/mimosa-react) to latest version of react-tools.
* Updated [mimosa-minify-css](https://github.com/dbashford/mimosa-minify-css) to latest version of clean-css
* Updated [mimosa-minify-js](https://github.com/dbashford/mimosa-minify-js) to latest version of uglify


## 2.2.18 - July 14 2014

### Minor Changes
* [mimosa-bower #39](https://github.com/dbashford/mimosa-bower/issues/39). Bumped to latest bower which fixes some recently caused trouble for those using latest bower via command line.
* [mimosa-plato](https://github.com/dbashford/mimosa-plato). Bumped to latest plato.
* [mimosa-sprite](https://github.com/dbashford/mimosa-sprite) was updated to match new `retrieveConfig` signature.  It also had its dependencies updated.
* [mimosa-minify-img](https://github.com/dbashford/mimosa-minify-img) was updated to latest image-min. Update includes removal of one of the previously avaiable config attributes.
* [mimosa-coffeelint](https://github.com/dbashford/mimosa-coffeelint). Updated coffelint dependency from `1.0.7` to `1.5.2`.
* [mimosa-server-template-compile](https://github.com/dbashford/mimosa-server-template-compile). Updated `hogan.js` from `2.0.0` to `3.0.2`
* [mimosa-require-lint #1](https://github.com/dbashford/mimosa-require-lint/issues/1). Fixed error when parsing AST and node was null.
* [mimosa-require-lint #2](https://github.com/dbashford/mimosa-require-lint/issues/2). Bumped esprima to latest.
* [mimosa-require-lint #3](https://github.com/dbashford/mimosa-require-lint/issues/3). Added `exclude` property.

## 2.2.17 - July 13 2014

### Major Changes
* [mimosa-web-package #20](https://github.com/dbashford/mimosa-web-package/issues/20)/[mimosa-web-package #22](https://github.com/dbashford/mimosa-web-package/issues/22). Huge archive generation updates. web-package can now create a `.zip` file for you. Additionally you can set `archiveName` to `null` to not generate an archive at all. And `"mimosa-config-documented.coffee",".mimosa","bower.json"` were added to the default set of files to leave out of the archive. web-package was bumped to `2.0`.

### Minor Changes
* [mimosa #403](https://github.com/dbashford/mimosa/issues/403). The signature to `retrieveConfig`, used when creating commands (like `mimosa sprite`) from external modules, has been simplified to `opts, callback`.  This allows for things like profiles to be passed.  The previous signature, `buildFirst, debug, callback` is still supported.  The previous first paramter, `buildFirst` should be attached to `opts` as `opts.buildFirst` and `debug` as `opts.mdebug`.
* [mimosa-jade #20](https://github.com/dbashford/mimosa-jade/issues/4). Updated `jade-runtime` to latest. Updated jade to `1.3.1`.

## 2.2.16 - July 7 2014

### Major Changes
* __New Module__: [mimosa-css-colorguard](https://github.com/dbashford/mimosa-css-colorguard). Will catch when colors in your CSS are close enough that maybe one ought to be eliminated.  Wraps the [css-colorguard](https://github.com/SlexAxton/css-colorguard) library.

### Minor Changes
* mimosa now assigns `isVendor` flag to individual files in its `options.files` array for processing of CSS.
* [mimosa-web-package #21](https://github.com/dbashford/mimosa-web-package/issues/21). Now properly handling users possibly having coffeescript 1.6 v 1.7.

## 2.2.15 - June 30 2014

### Minor Changes
* [mimosa #398](https://github.com/dbashford/mimosa/issues/398). Updated `mimosa new` message to be more clear.
* [mimosa-web-package #21](https://github.com/dbashford/mimosa-web-package/issues/21). Fixed mismatch between what new coffeescript projects were outputting as version numbers and what web-package was outputting for its `app.js` file.

## 2.2.14 - June 23 2014

### Major Changes
[mimosa #397](https://github.com/dbashford/mimosa/issues/397). You can now provide multiple profiles at the command line. Ex: `mimosa build -P foo#bar`.  Profiles are applied from left to right.  So, in this case if the `bar` profile contains the same configuration as the `foo` profile, the `bar` profile information will overwrite foo.

### Minor Changes
* [mimosa-server #6](https://github.com/dbashford/mimosa-server/issues/6). Exposing the server file and the server object on the mimosaConfig.  Can now access file and object from anywhere that has access to mimosaConfig.
* [mimosa-server-reload #7](https://github.com/dbashford/mimosa-server-reload/issues/7). Calling `preMimosaRestart` function if it exists to allow users to clean up connections, etc before restarting server.

## 2.2.13 - June 22 2014

### Major Changes
* __New Module__: [mimosa-cjsx](https://github.com/mtscout6/mimosa-cjsx). A Coffeescript + React/JSX compiler.

### Minor Changes
[mimosa #396](https://github.com/dbashford/mimosa/issues/396). Added `--nolazy` pass-through to node.

## 2.2.12 - June 19 2014

### Major Changes
* __New Skeleton__: [knockout](https://github.com/h-taylor/mimosa-knockout). Knockout, RequireJS, Less, Bower, Jasmine.

### Minor Changes
* [mimosa-web-package #18](https://github.com/dbashford/mimosa-web-package/issues/18). A PR fixed issue with `app.js` being generated when it wasn't needed.
* [mimosa-bower #38](https://github.com/dbashford/mimosa-bower/issues/38). Exposed `isInstalledNeeded` so it can be used by other modules.

## 2.2.11 - June 7 2014

### Minor Changes
* [mimosa-require #35](https://github.com/dbashford/mimosa-require/issues/35). r.js rebuilds should now happen on file change during `mimosa watch`.
* [mimosa-require #36](https://github.com/dbashford/mimosa-require/issues/36). Fixed issue with `module` based builds bombing during `mimosa watch`.  Should be able to re-run builds with file changes during `mimosa watch`.
* [mimosa-es6-module-transpiler](https://github.com/dbashford/mimosa-es6-module-transpiler). Upgraded to latest transpiler version, added `inferName` config.

## 2.2.10 - June 7 2014

### Minor Changes
* [mimosa-live-reload #5](https://github.com/dbashford/mimosa/pull/5). live-reload will now just refresh your CSS rather than reload the page if your "additional directories" have a `.css` file that changes.

## 2.2.9 - June 2 2014

### Minor Changes
* [mimosa #395](https://github.com/dbashford/mimosa/issues/395). Invalid `bower.json` will no longer crash `mimosa watch` after startup.

## 2.2.8 - May 30 2014

### Minor Changes
* Bumped version of mimosa-minify-js

## 2.2.7 - May 28 2014

### Minor Changes
* [mimosa #392](https://github.com/dbashford/mimosa/issues/392). Added `watch.delay` to handle cases when file events are sent before the file is finished being saved.

## 2.2.6 - May 19 2014

### Major Changes
* Related to [mimosa #391](https://github.com/dbashford/mimosa/issues/391), the `misc` compiler type -- added a month or so ago to represent those compilers which don't fit neatly into copying, javascript/css transpiling or template compiling -- have been thought through a bit more.  Now files having an extension mapped to a `misc` compiler will be read, their output will be written, and their output will be cleaned up during clean processing.
* All compilers are wrapped in a parent for their type.  So, in mimosa core, there is a JavaScript compiler wrapper for all the JavaScript compilers.  Previously, that wrapper would call a `compile` function on its wrapped compiler and that was the only compiler function that would get called as part of workflow processing.  Now a compiler can register for anything else by implementing its own `registration` function like every other non-compiler module.
* To see a sample `misc` compiler, checkout the [MimosaMiscCompilerExample project](https://github.com/dbashford/MimosaMiscCompilerExample).

### Minor Changes
* [mimosa-server #5](https://github.com/dbashford/mimosa-server/pull/5) (@ropez). This PR adds the ability for the mimosa-config to set variables for the views that Mimosa's default server uses from a Mimosa application.  `server.views.options` will now be added to the global variable config for a server view before serving it, allowing you to add custom variables to your server templates.
* [mimosa #391](https://github.com/dbashford/mimosa/issues/391). Add `misc` to compiler extension array.

## 2.2.5 - May 13 2014

### Major Changes
* As a part of [mimosa-bower #37](https://github.com/dbashford/mimosa-bower/issues/37), a new flag has been added to the `watch`, `build` and `clean` commands.  Add a `-C/--cleanall` and as Mimosa starts up it will remove the `.mimosa` directory. This allows for a forced reinstall of Bower components and forces other modules to rebuild their `.mimosa` cache.
* __New Module__:[mimosa-restart](https://github.com/dbashford/mimosa-restart). Restarts Mimosa within the same process when the `watch.compiledDir` is deleted.

## 2.2.4 - May 09 2014

### Major Changes
* __New Module__:[mimosa-svgs-to-iconfonts](https://github.com/dbashford/mimosa-svgs-to-iconfonts). Turns sets of `.svg` files into sets of `.svg`, `.eot`, `.woff`, `.ttf` font files and a corresponding `.css` file. Check out the [example app](https://github.com/dbashford/MimosaIconFontsExample) to see it working.
* mimosa-server's server and mimosa's watcher will now respond to a `STOPMIMOSA` signal that is sent through the Mimosa process via `process.send( "STOPMIMOSA" );`. This will more easily allow forked processes to shut down all of a Mimosa's process' activities.

## 2.2.2/2.2.3 - May 6 2014

### Major Changes
* More performance improvements, almost entirely lazy loading of libraries.

## 2.2.1 - May 5 2014

### Major Changes
* Beginning process of speeding up startup performance.  Delayed loading of modules in `skelmimosa` and in mimosa core.  Should improve startup a good deal.  More to come.

### Minor Changes
* [mimosa #390](https://github.com/dbashford/mimosa/issues/390). Fixing bug introduced with `2.2.0`, mimosa startup getting stuck if no javascript files have changed.

## 2.2.0 - May 5 2014

The slim possibility of a breaking change with [mimosa #382](https://github.com/dbashford/mimosa/issues/382) necessitated the bump to `2.2`, otherwise the number of changes to Mimosa's core was minimal.  It has been awhile since there was a release and plenty of modules and skeletons have been released since.

Wrapping up and releasing this change to core clears the way to get back to features and bug fixes with various key modules.

Next up is an attack on startup time.  Mimosa is super-fast once it gets going, but it can be a bit of a bear when it first starts up and there are a number of simple changes that can be made that should begin to address that.

### Major Changes
* __New Skeleton__: [marionette-semantic](https://github.com/Anachron/mimosa-marionette). Marionette, RequireJS, Express, Jade, Bower, CoffeeScript, LESS, Semantic-UI and more.
* __New Module__:[mimosa-testem-qunit](https://github.com/neverfox/mimosa-testem-qunit). A port of the mimosa-testem-require module to use qunit instead of mocha.
* __New Module__: [mimosa-d3-on-window](https://github.com/dbashford/mimosa-d3-on-window). Attaches d3 to the `window` object by modifying the source library. Allows for continuing to use bower to pull in d3 as build tool will always update d3 to attach it to `window`.
* __New Module__: [mimosa-adhoc-module](https://github.com/dbashford/mimosa-adhoc-module). A super simple and super powerful module. This module lets you register simple one-off modules that are local to your codebase by simply `require`ing them into your `mimosa-config`.
* __New Module__: [mimosa-jade-static](https://github.com/emirotin/mimosa-jade-static). A new template compiler, jade-static automatically executes compiled jade templates to generate the HTML.  It then does all that normal template compilers do.  It merges the HTML strings into a single file.
* [mimosa #382](https://github.com/dbashford/mimosa/issues/382). Mimosa is heavily extension based. Mimosa and its modules determine when to do what based on a file's extension.  Occasionally the same extension needs to have different things done. One example is when you want to have some `.html` based templates bundled together by Mimosa's [HTML-Template compiler](https://github.com/dbashford/mimosa-html-templates) and you want to have some `.html` files simply copied from the source directory to the compiled directory.  In that case two dramatically different compilers need to be invoked for the exact same file types.

    With `2.2` some things have changed with how compilers sort themselves out. Chiefly, those compilers that self-identify as `copy` or `misc` (as opposed to `javascript`, `css` or `template`) will be sorted to the end of the queue for priority for processing a file.  copy is very much a default sort of behavior, and if anything else wants to manage a file that is also managed by the copy compiler, copy should not win that conflict. So, as in the case above, if both the template compiler and the copy compiler both want to process an `.html` file, the template compiler will win.

    There is minor potential for this change to cause people some trouble, but it is largely unlikely.  Still, it was worth the larger version bump.

### Minor Changes
* [mimosa-coffeelint #3](https://github.com/dbashford/mimosa-coffeelint/pull/3). Via PR, coffeelint will now lint iced coffeescript files assuming you are using the mimosa-iced-coffeescript compiler.
* [server-template-compile](https://github.com/dbashford/mimosa-server-template-compile/). server-template-compile now will prettify HTML output if not using `minify` or `optimize` flags.
* [mimosa-web-package #12](https://github.com/dbashford/mimosa-web-package/pull/12). `npm install` is now run with `--production` flag.
* [mimosa-web-package #13](https://github.com/dbashford/mimosa-web-package/issues/13). Added `.travis.yml` to list of default excluded files from bundle.
* [mimosa-web-package #14](https://github.com/dbashford/mimosa-web-package/issues/14). Added `useEntireConfig` setting. Previously web-package would pluck what it thought was the important portions of the `mimosa-config` out and create the `config.js` with it.  This setting allows for using the entire config.
* [mimosa-coffeelint #4](https://github.com/dbashford/mimosa-coffeelint/pull/4). Improvements to logging.
* [mimosa-stylus #2](https://github.com/dbashford/mimosa-stylus/issues/2). stylus compiler now supports `@require` syntax for bringing files in.

## 2.1.22 - Mar 29 2014

### Minor Changes
* [mimosa #385](https://github.com/dbashford/mimosa/issues/385). mimosa-minify-css now allows configuring of the [clean-css options](https://github.com/GoalSmashers/clean-css#how-to-use-clean-css-programmatically). By default mimosa-minify-css will not strip `@import`s.
* [mimosa-client-jade-static #8](https://github.com/dbashford/mimosa-client-jade-static/pull/8). Brought client-jade-static to latest jade version.
* [mimosa-jade #1](https://github.com/dbashford/mimosa-jade/pull/1). Brought jade up to `1.3.0` of jade.

## 2.1.21 - Mar 26 2014

### Major Changes
* [mimosa-ember-handlebars #4](https://github.com/dbashford/mimosa-ember-handlebars/issues/4). Bumped version to `2.0.0` after removing `lib` option and switching to using npm installed packages for specific versions.  Now uses [ember-template-compiler](https://github.com/toranb/ember-template-compiler).
* [mimosa-emblem](https://github.com/dbashford/mimosa-emblem). Bumped version to `2.0.0` after removing `handlebarsLib` option and switching to using npm installed packages for specific versions.  Now uses [ember-template-compiler](https://github.com/toranb/ember-template-compiler).

### Minor Changes
* [skelmimosa #24](https://github.com/dbashford/skelmimosa/pull/24). `mimosa skel:list` should now work properly behind a proxy.
* [mimosa-client-jade-static #7](https://github.com/dbashford/mimosa-client-jade-static/pull/7). Now if compile fails during build the mimosa process will exit with error code.

## 2.1.20 - Mar 23 2014

### Major Changes
* __New Module__: [mimosa-vault](https://github.com/breathe/mimosa-vault). Mimosa module which uses the [vault](https://github.com/jcoglan/vault/tree/master/node) project to generate passwords derived from a secret key.
* __New Module__: [mimosa-inline-css-import](https://github.com/jbruni/mimosa-inline-css-import).  Will inline your CSS @import code into your stylesheet.
* [mimosa-require #31](https://github.com/dbashford/mimosa-require/issues/31). mimosa-require now has better support for require.js plugins. A new `require.verify.plugins` config allows you to configure which plugins you are using and what the extensions for those plugins are so the plugin paths can be validated.

### Minor Changes
* [mimosa-browserify](https://github.com/JonET/mimosa-browserify). By default source maps are now turned off during `mimosa build`.

## 2.1.19 - Mar 17 2014

### Major Changes
* __New Skeleton__: [react-backbone](https://github.com/dbashford/MimosaReactBackboneTodoList). A React, Backbone, Require.js, Bower Todo App.
* __New Module__: [mimosa-react](https://github.com/dbashford/mimosa-uncss). A new JavaScript compiler.  This compiles your React/JSX templates to JavaScript.
* __New Module__: [mimosa-uncss](https://github.com/dbashford/mimosa-uncss). Run this module over your css files and eliminate all the unused CSS from your application.  I ran this over my company's corporate sit and saved 77%!

### Minor Changes
* [mimosa & mimosa-ractive #1](https://github.com/dbashford/mimosa-ractive/issues/1). Mimosa's template compilers come with their own client libraries.  The determining factor for whether or not mimosa writes those libraries has been whether or not you are using AMD. Not long ago a `writeLibrary` config property was added.  This properly will now determine whether or not to write the client library.
* [mimosa-web-package #11](https://github.com/dbashford/mimosa-web-package/pull/11). Now properly registering coffeescript/iced in `app.js`.

## 2.1.18 - Mar 10 2014

### Minor Changes
* [mimosa #379](https://github.com/dbashford/mimosa/issues/379). mimosa-bower now handles `package.json` `main` a bit better, checking to see if the reference is to a folder/file and adjusting accordingly.

## 2.1.17 - Mar 7 2014

### Minor Changes
* Added `file.write` helper to mimosaConfig being passed around.  Saves modules from needing to deal with recursive directory creation.
* [mimosa-testem-require #10](https://github.com/dbashford/mimosa-testem-require/issues/10). Via PR all the libraries, sinon, chai, mocha, and sinon-chai, have been upgraded to their latest versions.
* [mimosa-ember-handlebars #3](https://github.com/dbashford/mimosa-ember-handlebars/issues/3/). Updated the Ember portion of the compiler.

## 2.1.16 - Mar 7 2014

### Minor Changes
* [mimosa-ember-handlebars #2](https://github.com/dbashford/mimosa-ember-handlebars/issues/2/). Fixed issue in mimosa core where compilers were getting registered twice during `mimosa build`.

## 2.1.15 - Mar 5 2014

### Major Changes
* A vast majority of the `mimosa-config-documented.coffee` properties will now show up uncommented.  This should make the `-documented` file easier to read and make it play nicer with syntax highlighting.

### Minor Changes
* [mimosa-emblem](https://github.com/dbashford/mimosa-emblem/) has been updated to the latest versions of emblem and handlebars.

## 2.1.14 - Mar 4 2014

### Minor Changes
* Quick patch for previous JSHint fixes.

## 2.1.13 - Mar 4 2014

### Minor Changes
* [mimosa-jshint](https://github.com/dbashford/mimosa-jshint/) now allows the `.jshintrc` to have comments.  Previously it had to be 100% valid JSON and comments were not allowed.

## 2.1.12 - Mar 4 2014

### Minor Changes
* [mimosa-require #30](https://github.com/dbashford/mimosa-require/issues/30). Adds support for [css](https://github.com/guybedford/require-css) plugin. Will not treat paths as javascript paths and will verify path exists in file system.

## 2.1.11 - Mar 3 2014

### Minor Changes
* Continuing to eliminate leading `#` in module placeholders.
* [mimosa-jshint](https://github.com/dbashford/mimosa-jshint/) has been updated to include the latest jshint.  The latest jshint includes support for `import 'foo'` es6 module syntax.

## 2.1.10 - Feb 28 2014

### Major Changes
* [mimosa #376](https://github.com/dbashford/mimosa/issues/376). Fixed issue with duplicate template names being improperly reported.
* [mimosa #375](https://github.com/dbashford/mimosa/issues/375). All of the `mimosa new` code, the command as well as the skeleton files, have been pulled into [newmimosa](https://github.com/dbashford/newmimosa/) and are brought into mimosa as a dependency.
* __New Module__: [mimosa-autoprefixer](https://github.com/dbashford/mimosa-autoprefixer). Will automatically apply CSS vendor prefixes. Includes source map support.

## 2.1.9 - Feb 25 2014

### Major Changes
* __New Skeleton__: [webapp](https://github.com/dbashford/MimosaWebAppSkeleton). A basic web app skeleton for a require.js application without client libraries.  Includes testing, minification of all assets and packaging.

### Minor Changes
* [mimosa #369](https://github.com/dbashford/mimosa/issues/369). Erroring out during `mimosa build` in a few more places, including in mimosa-require when files don't esprima parse correctly.
* Continuing to eliminate leading `#` in module placeholders.

## 2.1.8 - Feb 24 2014

### Minor Changes
* [mimosa #368](https://github.com/dbashford/mimosa/issues/368). Fixed issue with 368 where web-package was not getting new default.

## 2.1.7 - Feb 23 2014

### Major Changes
* __New Module__: [mimosa-minify-svg](https://github.com/dbashford/mimosa-minify-svg). New module to support minification of SVG assets.
* __New Module__: [mimosa-minify-html](https://github.com/dbashford/mimosa-minify-html). New module to support minification of HTML assets.

### Minor Changes
* [mimosa #368](https://github.com/dbashford/mimosa/issues/368). Updated mimosa-server to allow for `server.js` to be a default `server.path`. The code will now look for both `server.coffee` and `server.js` if a specific file path is not provided.
* [mimosa #368](https://github.com/dbashford/mimosa/issues/368). `mimosa new` will no longer override `server.path` if JavaScript or TypeScript picked as transpiler.
* [mimosa-sass #2](https://github.com/dbashford/mimosa-sass/pull/2). Added `includePaths` as additional configuration option for mimosa-sass.

## 2.1.6 - Feb 22 2014

### Major Changes
* __New Module__: [mimosa-nunjucks](https://github.com/dbashford/mimosa-nunjucks). New module to support compiling [nunjucks](http://jlongster.github.io/nunjucks/) micro-templates.
* [mimosa #232](https://github.com/dbashford/mimosa/issues/232). Added scaffolding to `mimosa new` for nunjucks.

## 2.1.5 - Feb 22 2014

### Major Changes
* __New Module__: [mimosa-stream-copy](https://github.com/dbashford/mimosa-stream-copy). Some files, like images or txt or font files, don't need to have anything done to them by any module. They just need to be copied from point A to point B. Source to public. mimosa-stream-copy will copy those files using super-fast streams and then stop the processing of those files.  Copying didn't take a long time without streams, but with this module it takes no time at all.
* __New Module__: [mimosa-minify-img](https://github.com/dbashford/mimosa-minify-img). This module adds a `mimosa minimage` command that will minify/optimize `png`, `gif`, `jpg` and `jpeg` files.

### Minor Changes
* Fixed issue with mimosa-require crashing on files not parsing properly

## 2.1.4 - Feb 20 2014

### Major Changes
* __New Module__: [mimosa-eslint](https://github.com/dbashford/mimosa-eslint). An [ESLint](http://www.eslint.org) module allows for performing next gen static analysis.
* [mimosa-require #29](https://github.com/dbashford/mimosa-require/issues/29). HUGE change for require.js users. mimosa-require will now use r.js' own esprima code to determine your dependencies and requirejs configuration. This will dramatically improve if not eliminate any false reports back from mimosa-require.  [Read more on the blog.](http://dbashford.github.io/mimosa-2-1-4-require-js-support-improvements-thx-r-js-esprima/index.html)

## 2.1.1, 2.1.2, 2.1.3 - Feb 15 2014

### Major Changes
* __New Module__: [mimosa-emberscript](https://github.com/dbashford/mimosa-emberscript). New JavaScript compiler for [EmberScript](http://emberscript.com/). Includes creation of source maps.
* __New Module__: [mimosa-groundskeeper](https://github.com/dbashford/mimosa-groundskeeper). A static analysis and code clean-up tool.  This will remove things like `console.log` and `debugger` statements from your code as well as pragmas. This wraps the great [groundskeeper tool](https://github.com/Couto/groundskeeper) and allows for all the same functionality.
* [mimosa-less #1, #2](https://github.com/dbashford/mimosa-less/pull/2). Via a great PR, mimosa-less now support less source maps.  Moar source maps ftw.

### Minor Changes
* Bumped JSHint to latest version to solve some issues with handling code output by EmberScript
* [mimosa #365](https://github.com/dbashford/mimosa/issues/365). mimosa-require will now build r.js configs one step earlier in the mimosa workflows, from `beforeOptimize` to `init`, so that modules that tweak the r.js config before r.js is run can register for `beforeOptimize` safely and not have `modules` array order be an issue.
* Bumped logmimosa version in skelmimosa package.

## 2.1.0 - Feb 12 2014

This release is entirely logging related.

### Major Changes
* Previous the logging config was under `growl` and the only configuration for logging related to when and if to send growl messages.  That will be changing, so the root config object will now simple be `logger`. For a short period of time the old `growl` config will be deprecated but supported with the exception being the various `onSuccess` flags.
* [mimosa #355](https://github.com/dbashford/mimosa/issues/355). The new `logger` config allows for Growl to be outright turned off.  `logger.growl.enabled`.
* [mimosa #344](https://github.com/dbashford/mimosa/issues/344). The new `logger` config allows for turning on/off `info`, `warn`, `error`, and `success` log levels.
* [mimosa #341](https://github.com/dbashford/mimosa/issues/341). With `2.1` mimosa now places the `logmimosa` instance on the mimosa-config object that gets passed to all of the modules for registration and for workflow execution.  It can be accessed at `mimosaConfig.log`.
* All of the modules maintained by me (dbashford) have had their `logmimosa` dependency removed.  Now all of those modules depend on the `logmimosa` that resides in Mimosa core.  This will let Mimosa core maintain the single logger instance which now has much more dynamic configuration.
* [mimosa #336](https://github.com/dbashford/mimosa/issues/336). The colorization of log messages has been changed dramatically. Previously the entire message was given a color.  Now only a single `ERROR`, `WARN`, `Debug`, `Info` string at the beginning of the log message is colorized.  Also, most messages had the key piece of the message wrapped in `[[`/`]]`.  Now by default the brackets are stripped and the contents of the brackets are given a different color.  The content of the brackets usually constituted an important piece of the message so it now draws focus.  Additionally it the content inside the brackets contains a file path, the path is shortened to be relative to the root directory of the project.  Previously it contained the absolute path.  All color options are configurable if the colors set in the defaults do not do it for you.
* The various `growl` `onSuccess` flags for `javascript`, `css`, etc are not being carried over to the new `logger` config.  `onSuccess` will be a flag itself rather than an object.

### Breaking Changes
* All of the modules have been updated to use the latest logging functionality.  The newest modules must be used with Mimosa `2.1` as the expect Mimosa to pass them the logger.  Using the most up to date modules with older versions of Mimosa will result in errors.
* Version `2.1` will work fine with older versions of modules except that the logging messages will bounce back and forth between the new logging (mimosa core `2.1`) and the old logging (from the module)
* If you were using (overriding) the `growl.onsuccess` flags, you'll find those flags are no longer available.  They have been removed.

## 2.0.8 - Feb 6 2014

### Major Changes
* [mimosa-sprite](https://github.com/dbashford/mimosa-sprite/). mimosa-sprite now supports LESS and SASS output.

### Minor Changes
* [mimosa #359](https://github.com/dbashford/mimosa/issues/359). `.mp3` was added to the default [copy compiler](https://github.com/dbashford/mimosa-copy/).
* [mimosa #358](https://github.com/dbashford/mimosa/issues/358). Some updates to CSS compilation to handle widely varying import syntax as compilers improve and allow different types of syntax.
* [mimosa-less](https://github.com/dbashford/mimosa-less/) and [mimosa-sass](https://github.com/dbashford/mimosa-sass/) were both updated to allow for handing variable import syntax.
* [mimosa-less](https://github.com/dbashford/mimosa-less/). Fixed mimosa-less logic for finding the base less files.
* [mimosa-handlebars](https://github.com/dbashford/mimosa-handlebars/). Bumped handlebars version to `1.1`
* [mimosa-ember-handlebars](https://github.com/dbashford/mimosa-ember-handlebars/). Bumped handlebars version to `1.1`
* [mimosa-es6-module-transpiler #1](https://github.com/dbashford/mimosa-es6-module-transpiler/issues/1). Updated the default `excludes` to include other common require.js conventions.

## 2.0.7 - Feb 5 2014

This release just solved some problems with NPM not properly installing Mimosa.

## 2.0.6 - Feb 1 2014

### Minor Changes
* [mimosa #356](https://github.com/dbashford/mimosa/issues/356). Now registering coffeescript if coffeescript config file detected.

## 2.0.5 - Jan 31 2014

### Minor Changes
* [mimosa-require #28](https://github.com/dbashford/mimosa-require/pull/28). Fixed issue where the r.js `optimize` flag could not be overridden.
* [skelmimosa](https://github.com/dbashford/skelmimosa). Updated `mod:list` be more compact, view better with fewer columns.  Updated dependencies.

### External Module Updates
* [mimosa-coffeelint #2](https://github.com/dbashford/mimosa-coffeelint/pull/2). Via PR, got coffeelint working with mimosa 2.0.  Also upgraded coffeelint.
* [mimosa-coffeescript](https://github.com/dbashford/mimosa-coffeescript) and  [mimosa-iced-coffeescript](https://github.com/dbashford/mimosa-iced-coffeescript) were both updated to their latest versions with the release of CoffeeScript 1.7.

## 2.0.4 - Jan 28 2014

### Major Changes
* __New Module__: [mimosa-handlebars-on-window](https://github.com/dbashford/mimosa-handlebars-on-window). A dead simple module that will alter `handlebars.js` source slightly to attach `Handlebars` to the `window` object. Solves some current issues with Ember.js and r.js optimized builds.  Also allows for managing Handlebars via Bower.

### Minor Changes
* [mimosa #354](https://github.com/dbashford/mimosa/issues/354). Added `template.writeLibrary` config to allow for not writing template libraries, like `handlebars.js`.  By default Mimosa's template compiler functionality will write an AMD version of the client library.

## 2.0.3 - Jan 27 2014

### Minor Changes
* [mimosa #353](https://github.com/dbashford/mimosa/issues/353). Fixed issue with CSS compiler caused when name of folder included extension of compiler.  For instance, `normalize.styl/normalize.styl`.

## 2.0.2 - Jan 27 2014

### Minor Changes
* [skelmimosa #22](https://github.com/dbashford/skelmimosa/issues/22). `mimosa skel:new` will now automatically clean up any `.gitkeep` files that might be laying around the skeleton.
* [mimosa #351](https://github.com/dbashford/mimosa/issues/351). Fixed problem with `mimosa new` and folders that had both dashes and dots in the name, like `/www.my-site.com/`.

## 2.0.1 - Jan 26 2014

### Major Changes
* __New Module__: [mimosa-generator](https://github.com/dbashford/mimosa-regenerator). This module will transpile your ES6 generators down to valid ES5 javascript.

### Minor Changes
* [mimosa-web-package #9](https://github.com/dbashford/mimosa-web-package/pull/9). This PR to web-package allows config files to be outside the root of the distributed web package.
* Fixed `mimosa config` help message.

## 2.0.0 - Jan 23 2014

Note: Some skeletons may take some time to be updated for the changes to `2.0`.  All skeletons at least have a pending pull request to make the needed changes.

With `2.0` all of Mimosa's compilers, which were previously internal to Mimosa, are now external in their own modules. So, for instance, this means there is now a [mimosa-coffeescript](https://github.com/dbashford/mimosa-coffeescript) module and a [mimosa-stylus](https://github.com/dbashford/mimosa-stylus).  All of the JavaScript transpilers, CSS proprocessors, micro-template compilers, and the copy "compiler" have their own Mimosa modules.

This shrinks Mimosa core's footprint by an enormous amount, making it quicker to `npm install` and easier to maintain.  It also makes compilers easier to manage and update on their own while also making it much easier to add new compilers.  Previously a new compiler would have been a PR to Mimosa core, now it can be a module on its own.

### Huge Changes
* All JS/CSS/Template compilers have been pulled out of Mimosa and into their own modules.
* File copying support, for images or `.js`/`.css` files for example has also been pulled into its own module: [mimosa-copy](https://github.com/dbashford/mimosa-copy).
* `mimosa new` received an overhaul that allows it to pull in needed compilers and build a mimosa-config based on those external modules.
* The handlebars micro-template compiler was broken into two pieces, one for ember.js flavored handlebars and one for vanilla handlebars. Previously there was one compiler that supported both, but for ease of use they were broken out.
* The `compilers` config has been eliminated. Previous the `compilers` config is how you would override the default extensions for a compiler or provide a specific compiler library (like a specific version of Handlebars) for Mimosa to use when compiling files. Both of these responsibilities now reside with the individual broken out compilers. All of the individual compilers now manage their own extensions and compiler library overrides.

### Major Changes
* All of the compilers are now written in JavaScript rather than CoffeeScript.
* The mimosa-config generated by `mimosa new` will be a JavaScript file and be reduced down to only the needed config without comments.  A 2nd file (called `mimosa-config-documented.coffee`) with all the comments for all of the modules will be generated at the same time.
* `mimosa config` will now generate a `mimosa-config-documented.coffee` instead of a `mimosa-config-commented.coffee`.
* `mimosa new` will no longer deliver Emblem assets. It will also not deliver Ember-Handlebars assets. Both of those require Ember and I rather `mimosa new` not be opinionated in that regard.
* [mimosa #348](https://github.com/dbashford/mimosa/pull/348). An awesome PR provides support for multi-line SASS imports so that things like Foundation will compile out of the box without orphan file issues.

### Minor Changes
* [mimosa #340](https://github.com/dbashford/mimosa/pull/340). `mimosa new` can now handle absolute paths.
* [mimosa #333](https://github.com/dbashford/mimosa/pull/333). mimosa-bower now ignores and removes from processing any packages that `bower.paths` cannot track down.
* [mimosa #277](https://github.com/dbashford/mimosa/pull/277). mimosa-coffeescript and mimosa-iced-coffeescript both have been switched to the latest source map comment spec.  See [this thread](https://groups.google.com/forum/#!topic/mozilla.dev.js-sourcemap/4uo7Z5nTfUY/discussion) for more details on the difference between conditional and non-conditional source maps.  A configuration has been added to allow for switching back to conditional source maps if your browser does not support the latest spec.
* [mimosa-require #27](https://github.com/dbashford/mimosa-require/issues/27). Fixed issue where `mimosa watch` + `--optimize` + template file change would not trigger a rebuild of r.js optimized files.
* The mimosa-server module now depends on the installed node.js modules of your project for transpiler support.  For example, if Mimosa is running your server and your server is written in CoffeeScript, you'll need to have `coffee-script` installed in your project. mimosa-server will look for it there. This only effects those running node servers in a language that needs to be transpiled.

### You will need to... (Breaking Changes)
* If you are using a JavaScript transpiler, a CSS proprocessor or a micro-templater, you will need to find the corresponding new Mimosa module and include it in your project by adding it to the `modules` array. For example, to include CoffeeScript and Stylus, add `"coffeescript"` and `"stylus"` to your modules array.
* `template.handlebars` configuration has been removed/moved to the Handlebars and Ember-Handlebars compilers. If you have any specific `template.handlebars` config, you'll want to check the GitHub for those compilers to see how to move the config over.
* If you provide specific configuration to any of your compilers, like `stylus` or `template.handlebars`, then when you include the new module for that compiler, take a second to review the README on that module's GitHub page for details about the configuration.  All configuration has been preserved, but some of it has moved around.
* If you have any files that need copying (rather than compiling), like `.js` or `.css` or images, then add `"copy"` to your modules array. The copying functionality was also broken out into its own module.
* Have you provided any `compilers` configuration? You will have some changes to make as that configuration has been eliminated. All of the new compiler modules allow for overriding extensions and providing specific versions of a node compiler (like Handlebars). Check the documentation for the modules you use for more information.
* Running a node.js server in a language other than JavaScript? You'll need to `npm install` that transpiler in order to get Mimosa to successfully start your server.
* The Emblem compiler now only supports Ember.js based compilation. It is assumed if you are using Emblem that you are using Ember.