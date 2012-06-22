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
 * Growl notifications along with basic console logging.  If a compile fails, you'll know right away.
 * Automatic CoffeeLinting
 * Automatic JSHinting of compiled code
 * Basic Express skeleton to put you on the ground running with a new app
 * Bundled Express for serving up assets to an existing app
 * Run in development with unminified/non-compressed javascript, turn on prod mode and run with a single javascript file using Require's optimizer
 * Live Reload built in, without the need for a plugin

#### Which meta-languages?

 Future additions are planned, but for now...

 * CSS: sass (default)
 * Micro-templating: handlebars (default), dust
 * JavaScript: coffeescript (default), iced coffeescript

## Installation

    $ npm install -g mimosa

## Quick Start

 The easiest way to get started with mimosa is to use the command line to
 create a new application skeleton. By default, mimosa will create a basic
 express app configured to match all of mimosa's defaults.

 First navigate to a directory within which you want to place your application.

 Create the default app:

    $ mimosa new -n nameOfApplicationHere

 Change into the directory that was created and execute:

    $ mimosa watch --server

 Mimosa will watch your assets directory and compile changes made to your public directory.  It will also give you console and growl notifications for compilation results and code quality as files as saved.

## Configuration

 I built the configuration to be self-documenting.  The config file that comes bundled with the application contains all of the configurable options within the application and a brief explanation.  The default config is entirely commented out as the defaults are built into Mimosa.

 To change something, for instance, to make it so you don't get notified via growl when your CSS meta-language (like SASS) compiles successfully, uncomment the object structure that leads to the setting.  In this case you'd uncomment compilers, css, and notifyOnSuccess, and change the setting to false.

 You can find the configuration [inside the skeleton directory](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/config.coffee).

## Significant Known Issues

 * NODE_ENV=production can't be used straight away in a brand new project with uncompiled assets.  The require.js optimizer will choke.  Run it in dev mode first to get things compiled, then switch to production.  Fixing this will require a deeply necessary but chunky refactor.

## Roadmap

 * No write mode.  Just compilation with notifications, coffee/jshinting.
 * Stylus, LESS compilers
 * Example templates beyond the one provided
 * Proper life cycle for compilation which should allow for easier plugging in of new steps/compilers, etc
 * Tests for the Mimosa codebase
 * Integrated testing framework for your codebase