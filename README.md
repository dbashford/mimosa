mimosa - a modern browser development toolkit
======

Mimosa is a browser development toolkit, targeted at folks using meta-languages like CoffeeScript or SASS, or micro-templating libraries like Dust and Handlebars.  The toolkit is opinionated towards the use of [RequireJS](http://requirejs.org/) for dependency management, and comes bundled with useful tools like coffee/jshint to improve code quality and livereload to speed up development.

Mimosa is not quite ready for prime-time (as of late June), still shaking things out, but feel free to play around and file issues should you find them.

## Features

 * Sane defaults allow you to get started with 0 configuration.  All you really need is an assets and a public directory.
 * Heavily configurable if moving away from defaults
 * Compiling of CoffeeScript + Iced CoffeeScript
 * Compiling of SASS (soon, LESS, Stylus)
 * Compiling of Handlebars and Dust templates into single template files
 * Compile assets when they are saved, not when they are requested
 * Run in development with unminified/non-compressed javascript, turn on prod mode and run with a single javascript file using Require's optimizer and [Almond](https://github.com/jrburke/almond)
 * Growl notifications along with basic console logging.  If a compile fails, you'll know right away.
 * Automatic CoffeeLinting
 * Automatic JSHinting of compiled code
 * Basic Express skeleton to put you on the ground running with a new app
 * Bundled Express for serving up assets to an existing app
 * Live Reload built in, without the need for a plugin

#### Which meta-languages?

 Future additions are planned, but for now...

 * CSS: SASS (default)
 * Micro-templating: Handlebars (default), Dust
 * JavaScript: CoffeeScript (default), Iced CoffeeScript

## Installation

 When I feel Mimosa is a bit closer to being ready to go, I'll get it into NPM.  To get it before then...

    $ git clone ...
    $ cd mimosa
    $ npm install -g

## Quick Start

 The easiest way to get started with mimosa is to create a new application skeleton. By default, mimosa will create a basic express app configured to match all of mimosa's defaults.

 First navigate to a directory within which you want to place your application.

 Create the default app:

    $ mimosa new -n nameOfApplicationHere

 Change into the directory that was created and execute:

    $ mimosa watch --server

 Mimosa will watch your assets directory and compile changes made to your public directory.  It will also give you console and growl notifications for compilation results and code quality as files as saved.

## Configuration

 I built the configuration to be self-documenting.  The config file that comes bundled with the application contains all of the configurable options within the application and a brief explanation.  The default config is entirely commented out as the defaults are built into Mimosa.

 To change something -- for instance to make it so you don't get notified via growl when your CSS meta-language (like SASS) compiles successfully -- uncomment the object structure that leads to the setting.  In this case you'd uncomment compilers, css, and notifyOnSuccess, and change the setting to false.

 You can find the configuration [inside the skeleton directory](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/config.coffee).

## Immediate Feedback

 Compilation of your assets is kicked off as soon as a file is saved.  Mimosa will write to the console the outcome of every compilation event.  Should compilation fail, the reason will be included in the log message.

 If you have [Growl](http://growl.info/) installed and turned on, for each failure or successful compile of your meta-CSS/JS/Templates, you'll get a Growl notification.  In the event Growl gets too spammy for you, you can turn off Growl notifications for successful compiles.  Each compiler, CSS, JS, and Template, has a setting, `notifyOnSuccess`, that when enabled and set to false will stop Growl notifications for successful compilations.  You cannot turn off Growl notifications for compilation failures.

## CoffeeLint

 Mimosa will [CoffeeLint](http://www.coffeelint.org/) your CoffeeScript and CoffeeScript-based dialects.  Any CoffeeLint warnings will be printed to the console.  The default CoffeeLint configuration is included in the Mimosa configuration (commented out of course).  Turn rules on/off or change values to suit your needs.  You can also turn off CoffeeHint-ing altogether by enabling the `compilers.javascript.metalint` option, and switching it to false.

## JSHint

 Mimosa will [JSHint](http://www.jshint.com/) your compiled JavaScript.  Any JSHint warnings will be printed to the console.  JSHint has [many rules](http://www.jshint.com/options/), and for now overrides are not available via Mimosa.  But it wouldn't be hard to add if there is interest.  You can turn off JSHint altogether by enabling the `compilers.javascript.lint` option and switching it to false.

## RequireJS Optimization

 Start mimosa watching with the NODE_ENV production flag turned on and Mimosa will run RequireJS's optimizer on start-up and with every javascript file change.  The default Jade templates are built to switch on the environment.  So when you point at either the Express or default server's base URL with production switched on, you will be served the result of RequireJS's optimization, packaged with Almond.

 To start up with production turned on, execute the following:

    $ NODE_ENV=production mimosa watch --server

## Roadmap

 * No write mode.  Just compilation with notifications, coffee/jshinting.
 * Stylus, LESS compilers
 * Example templates beyond the one provided
 * Tests for the Mimosa codebase
 * Integrated testing framework for your codebase