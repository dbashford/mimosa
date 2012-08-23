Mimosa - a modern browser development toolkit
======

Mimosa is a browser development toolkit, targeted at folks using meta-languages like (but not limited to) CoffeeScript or SASS, and micro-templating libraries like Jade, Handlebars and Underscore.  Mimosa is opinionated towards the use of [RequireJS](http://requirejs.org/) for dependency management and has a lot of support built around it.  Mimosa comes bundled with useful tools like js/css hint to improve code quality and live reload to speed up development.  Read through the entire [feature set](#features)!

And know there is more to come!  Mimosa is in full dev mode on its way to feature completeness, however, everything listed in this README should (mostly) work.

[Give it a whirl](#quick-start).  Please do [file issues](https://github.com/dbashford/mimosa/issues) should you find them, and don't hesitate to [request features](https://github.com/dbashford/mimosa/issues).  I haven't spent time testing Mimosa on Windows, so I wouldn't be surprised to learn it has issues.

See Mimosa in action, check out a [demo app](https://github.com/dbashford/AngularFunMimosa).

## Features

 * Sane defaults allow you to get started without touching the configuration
 * Command line prompting during project creation to get you the configuration you want without having to comb through JSON and learn Mimosa's settings
 * A very simple (eventually less simple!) skeleton app build using the chosen meta-languages
 * Heavily configurable if moving away from defaults
 * Compiling of CoffeeScript + Iced CoffeeScript
 * Compiling of SASS (w/compass), LESS, and Stylus (w/nib)
 * Compiling of Handlebars, Dust, Hogan, Jade, Underscore, LoDash, and HTML templates into single template files to be used in the client
 * Compile assets when they are saved, not when they are requested
 * Growl notifications along with basic console logging, so if a compile fails, you'll know right away
 * Run in development with unminified/non-compressed javascript.  Turn on optimization and run with a single javascript file using RequireJS's optimizer and [Almond](https://github.com/jrburke/almond) with no need to configure the optimizer
 * Verify your RequireJS paths, catch circular dependencies and unwrapped modules in your application right away
 * Install dependencies like jquery or backbone into your project from GitHub via the command line
 * Automatic JSHinting, and CSSLinting
 * Basic Express skeleton to put you on the ground running with a new app, and a bundled Express for serving up assets to an existing app
 * Automatic static asset Gzip-ing, and cache busting
 * Live Reload built in, without the need for a plugin

### Why Mimosa?

What I wanted from Mimosa was a fast nothing-to-coding user-friendly experience.  Little-to-no mucking with config to get you started, no installing extra stuff yourself.  I want to deal with individual files during development, and let RequireJS handle optimized builds.  I want linting, gzip, live reload, and cache-busting all just there.  And I wanted real first-class support for RequireJS/AMD.

Much love and credit to [Brunch](http://brunch.io/) for the inspiration (hence 'Mimosa'), and for being the codebase I referenced when I had a problem to solve.  There's a lot here that Brunch does similarly, but also quite a bit I think Mimosa does differently.  I suggest you check Brunch out; it is awesome sauce.

Something missing from Mimosa for the short-term, that Brunch has in abundance, is a group of pre-built skeletons to get you started with things like Backbone and Bootstrap.  Those'll come after what I feel is the core feature set is complete and solid.

## Table Of Contents

- [Features](#features)
	- [Why Mimosa?](#why-mimosa)
- [Table Of Contents](#table-of-contents)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Command Line](#command-line)
	- [Help](#help)
	- [Debug Mode (-D, --debug)](#debug-mode--d---debug)
- [Meta-Language Compilation](#meta-language-compilation)
- [Asset Copying](#asset-copying)
- [Optimize](#optimize)
	- [RequireJS support, JavaScript Optimization](#requirejs-support-javascript-optimization)
		- [RequireJS Optimizer Defaults](#requirejs-optimizer-defaults)
	- [CSS Minification](#css-minification)
- [Immediate Feedback](#immediate-feedback)
	- [Growl](#growl)
- [Linting Your JavaScript and CSS](#linting-your-javascript-and-css)
	- [Linting Compiled Assets](#linting-compiled-assets)
	- [Linting Copied Assets](#linting-copied-assets)
	- [Linting Vendor Assets](#linting-vendor-assets)
	- [Lint Rules](#lint-rules)
	- [JSHint, CSSLint](#jshint-csslint)
- [Live Reload](#live-reload)
- [GZip](#gzip)
- [Cache Busting](#cache-busting)
- [Roadmap](#roadmap)
- [Suggestions? Comments?](#suggestions-comments)
- [License](#license)

## Installation

http://mimosajs.com/started.html#install

## Quick Start

http://mimosajs.com/started.html#quick

## Configuration

Mimosa's documentation is self-explanatory. The config file that comes bundled with the application contains all of the configurable options within the application and a brief explanation.  If you stick with the default options, like using CoffeeScript, Handlebars, and SASS, the configuration will be entirely commented out as the defaults are built into Mimosa.

To change something -- for instance to make it so you don't get notified via growl when your CSS meta-language (like SASS) compiles successfully -- uncomment the object structure that leads to the setting.  In this case you'd uncomment `growl.onSuccess.css`, and change the setting to `false`.

You can find the configuration [inside the skeleton directory](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee).

## Command Line

http://mimosajs.com/commands.html

### Help

Mimosa includes extensive help documentation on the command line for each of the commands.  Give them a peek if you can't remember an option or can't remember what a command does.  Use `--help` or `-h` to bring up help. For example:

    $ mimosa --help
    $ mimosa new -h

### Debug Mode (-D, --debug)

All Mimosa commands have a debug mode that will print detailed logs to the console for everything Mimosa is doing.

    $ mimosa [command] --debug
    $ mimosa [command] -D

## Meta-Language Compilation

http://mimosajs.com/compilers.html

## Asset Copying

http://mimosajs.com/compilers.html#copy

## Optimize

In the normal course of development, for debugging purposes, files should be loaded individually, rather than in one merged file, and you don't want your assets minified.  This all makes for easier debugging.

But when you take your application outside of development, you want to include all the performance improvements that come with merging, optimizing, and minifying your assets.  For both the `build` and `watch` commands, Mimosa provides an `--optimize` flag that will turn on this optimization.

Templates are merged together regardless, but they have source information included to make it easy to track back to the destination file, and templates will (ideally) be logic-less and less prone to problems.

### RequireJS support, JavaScript Optimization

Mimosa is loaded with AMD/RequireJS support.  Mimosa will..

 * Verify your module paths when your JavaScript meta-language (or JS itself) successfully compiles.  Mimosa will follow relative paths for dependencies, and also use your config paths whether they resolve to an actual dependency, ` jquery: 'vendor/jquery'`, or they resolve to a module, `moduleX:'a/path/to/module/x'`. Mimosa will also keep track of `map` settings and use them for path verification.  Path verification is enabled by default, but can be disabled by setting `require.verify.enabled` to false.
 * Alert you when paths are broken.  An unresolved path is as crucial as a compiler error; code is broken.  Should a path not be resolved, Mimosa will both write to the console and alert via Growl.
 * Catch when you have a circular dependency in your application and notify you on the console.
 * Catch when you have failed to wrap a non-vendor piece of compiled JavaScript in `require` or `define` and notify you on the console.
 * Run RequireJS' optimizer when the `optimize` flag is enabled for `mimosa build`, and on every file change for `mimosa watch`.
 * Need no config at all for the optimizer, which typically takes some time to configure.  Mimosa will keep track of your dependencies and build a vanilla optimizer configuration for you.
 * Handle multiple RequireJS modules just fine
 * Only compile those modules that need compiling based on the code that just changed
 * Bundle your optimized JavaScript with [Almond](https://github.com/jrburke/almond)

#### RequireJS Optimizer Defaults

Mimosa will infer the following default settings for the built-in [r.js optimizer](https://github.com/jrburke/r.js/).

 * `baseUrl`: set by combining the mimosa-config `watch.compiledDir` with the `compilers.javascript.directory`
 * `out`: optimized files are output into the `watch.compiled` + `compilers.javascript.directory` in a file that is your main module name + `-built.js`
 * `mainConfigFile`: set to the file path of the main module
 * `findNestedDependencies`: `true`
 * `wrap`: `true`
 * `include`: set to the name of the module being compiled
 * `insertRequire`: set to the name of the module being compiled
 * `name`: set to `almond`

These settings will package up each individual module you have into its own optimized file wrapped with Almond.

You can include any of the other RequireJS optimizer [configuration options](http://requirejs.org/docs/optimization.html#options) in the mimosa-config.  Simply uncomment the `require.optimize.overrides` setting and toss your settings in there.  You can both override and remove settings.  If you want to override a Mimosa setting, just put it in the `overrides`.  If you want a Mimosa default setting removed, set it to `null`.  For instance setting `mainConfigFile : null` will blank out that setting and it will not be passed to the optimizer.

You can also choose to not have Mimosa infer anything and to go entirely with your own configuration.  Set `require.optimize.inferConfig` to false and Mimosa will run r.js with the settings you give it

Also use `require.optimize.inferConfig:false` if you choose to have your configuration settings in script tags in an HTML file, or in any other file that does not compile to JavaScript.  For now, Mimosa is only able to make inferences for configs in JavaScript files.  If your configuration (and `require`/`requirejs` method calls) are in script tags on an HTML page, Mimosa will not find any modules to compile for optimization and therefore will not run optimization, so you'll need to provide your own configuration in `overrides` and set `inferConfig` to false

### CSS Minification

 When the `--optimize` flag is used, Mimosa will minify all of your compiled CSS files.

## Immediate Feedback

 Compilation of your assets is kicked off as soon as a file is saved.  Mimosa will write to the console the outcome of every compilation event.  Should compilation fail, the reason will be included in the log message.

### Growl

 If you have [Growl](http://growl.info/) installed and turned on, for each failure or successful compile of your meta-CSS/JS/Templates, you'll get a Growl notification.  In the event Growl gets too spammy for you, you can turn off Growl notifications for successful compiles.  Growl has its own setting in Mimosa, the defaults look like this:

```
# growl:
  # onStartup: false
  # onSuccess:
    # javascript: true
    # css: true
    # template: true
    # copy: true
```

If you [clean](#clean-compiled-assets-clean) your project and then start up the [watcher](watch-and-compile-watch), Mimosa will compile every asset you have.  If you have dozens or hundreds of assets, you may not want Growl notifications for each successful compile during this startup.  Startup success notifications are off by default.  You can turn on by uncommenting the config and setting the `growl.onStartup` flag to true.

You can also choose to turn off post-startup success notifications for compiled javascript, css, and templates, as well as for copied assets by altering the `growl.onSuccess` flats.  These notifications are on by default.

## Linting Your JavaScript and CSS

To 'lint' your code is to check it for common mistakes or variances from the idiom.  Mimosa will automatically lint all of the CSS and JavaScript it moves from your source directories to your compiled directories.  Any errors or warnings that come out of that linting will be printed to the console but will not stop or fail the compilation.  Inside the mimosa-config is this snippet which controls the linting.

```
# lint:
  # compiled:
    # javascript:true
    # css:true
  # copied:
    # javascript: true
    # css: true
  # vendor:
    # javascript: false
    # css: false
  # rules:
    # js:
      # plusplus: true
    # css:
      # floats: false
```

As with all of the default config, this is entirely commented out as the defaults are already enforced.

### Linting Compiled Assets

The `compiled` block controls whether or not linting is enabled for compiled code.  So if you've written SASS, LESS or Stylus, when Mimosa compiles it, Mimosa will send the resulting CSS through a linting process.  Similarly for the JavaScript meta-languages, Mimosa will lint the resulting JavaScript.

### Linting Copied Assets

If you've chosen to code js/css by hand, or if you've included a library written in js/css, the `copied` settings determine whether or not to lint those files.

### Linting Vendor Assets

Mimosa also allows you to control the linting of code contained in your `vendor` directory.  Linting is, by default, disabled for vendor assets, that is, those assets living inside a `/vendor/` directory.  Vendor libraries often break from the idiom, or use hacks, to solve complex browser issues for you.  For example, when run through CSSLint Bootstrap causes 400+ warnings.

If you want vendor asset hinting turned on, simply enable the setting and switch the flags to true.

### Lint Rules

The `rules` block is your opportunity to override and change the linting rules for each of the linting tools.  Example overrides are provided in the default configuration.  Those are examples, they are not actually overrides.

### JSHint, CSSLint

All of the lint/hinters come with default configurations that Mimosa uses.  Here are links to the tools, as well as to the configuration for those tools.

 * [JSHint](http://www.jshint.com/), [JSHint Config](http://www.jshint.com/options/)
 * [CSSLint](http://csslint.net/), [CSSLint Config](https://github.com/stubbornella/csslint/wiki/Rules)

## Live Reload

The default application you are provided comes built with live reload included.  Live Reload will immediately reload your web page any time an asset is compiled or one of your views changes.  So, for instance, if you change some LESS code, the instant it is compiled, and the compiled .css file is written to your `compiledDir`, your browser will update and your CSS updates will be displayed.

For those using the server code delivered to them via `mimosa new`, you have the ability to tweak how the reload works in the [`server.coffee`](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/server.coffee).  The library used for providing the Live Reload functionality is [watch-connect](https://github.com/Filirom1/watch-connect), and the github page has an explanation of the options you can pass in.  By default the reload will fire whenever the code in the `watch.compiledDir` changes, and whenever the code in the `view` directory of the application changes.  You have the ability to add more directories, and to exclude files from causing a reload using regexes.

To perform the Live Reload, the default application is built to include two extra libraries, including socket.io, to talk to the server and determine when to reload the page.  If you wish to turn this off, and thereby not include the two extra files, go into the mimosa-config.coffee file and update `server.useReload` to false.  These two extra files do not get wrapped up by RequireJS.

## GZip

 All your static assets will be served up GZip-ed!  'nuff said.

## Cache Busting

 No forcing a refresh to bypass caching issues.  All JavaScript and CSS files are cache-busted.

## Roadmap

  Many little bits and pieces, but the big ones are, in no certain order:

 * windows support
 * compile and run templates down to html for static site generation, for mimosajs.com for instance
 * package command
 * image optimization
 * example skeletons with things like Backbone/Chaplin/Angular/Ember, Bootstrap, etc
 * Tests for the Mimosa codebase
 * Integrated testing framework for your codebase

## Suggestions? Comments?

 @mimosajs

## License

(The MIT License)

Copyright (c) 2012 David Bashford

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.