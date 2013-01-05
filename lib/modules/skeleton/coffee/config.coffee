#### Module Configuration

# The code contained herein is all example code and shouldn't be used verbatim.
# The example in this case is modified from the mimosa-minify module.

"use strict"

# The defaults function should return a JSON object containing the default
# config for your module. If your module has no config, the function can be
# removed or return null. Mimosa uses this function when applying default
# configuration to a user's config.

exports.defaults = ->
  minify:
    exclude:["\\.min\\."]

# The placeholder function should return a string that represents the
# mimosa-config placeholder for your configuration defaults including
# explanations for each config setting where appropriate.  The content
# of the string should be all commented out. If you have no config,
# the function can be removed or can return null.  This function is called
# when Mimosa is creating an initial mimosa-config using 'mimosa new' or
# 'mimosa config'

exports.placeholder = ->
  """
  \t

    \# minify:                      \# Configuration for non-require minification/compression via uglify
                                 \# using the --minify flag.
      \# exclude:[/\.min\./]    \# List of regexes to exclude files when running minification.
                                 \# Any path with ".min." in its name, like jquery.min.js, is assumed to
                                 \# already be minified and is ignored by default. Override this property
                                 \# if you have other files that you'd like to exempt from minification.
  """

# The validate function should take a config object (which is the entire
# mimosa-config), find the module specific config, validate the settings
# and return a list of strings that are validation error messages. If
# there are no errors, return an empty array or return nothing.  Mimosa
# uses this function when Mimosa starts up to ensure the configuration
# has been set properly.

exports.validate = (config) ->
  errors = []
  if config.minify?
    if typeof config.minify is "object" and not Array.isArray(config.minify)
      if config.minify.exclude?
        if Array.isArray(config.minify.exclude)
          for ex in config.minify.exclude
            unless typeof ex is "string"
              errors.push "minify.exclude must be an array of strings"
              break
        else
          errors.push "minify.exclude must be an array."
    else
      errors.push "minify configuration must be an object."

  # The validate function is also an opportunity to do configuration massaging,
  # for instance, turning a list of strings into a single RegExp.  Changes
  # made to the config inside validate are permament and carried throughout
  # the currently running Mimosa process.

  if errors.length is 0 and config.minify.exclude?.length > 0
    config.minify.exclude = new RegExp config.minify.exclude.join("|"), "i"

  errors
