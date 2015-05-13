path    = require 'path'
fs      = require 'fs'

# Emblem template compiler
Emblem  = require('../vendor/emblem/emblem').default

module.exports = class EmblemCompiler
  brunchPlugin: yes
  type:         'template'
  extension:    'emblem'
  pattern:      /\.(emblem|hbs|handlebars)$/

  constructor: (@config) ->
    templateCompilerPath = path.resolve @config.files.templates.paths.ember_compiler
    @htmlbarsCompiler = require(templateCompilerPath)

  normalizeName: (name) ->
    # strip extension
    name.replace(/\.\w+$/, '')

  compile: (data, compilePath, callback) ->
    extension  = path.extname(compilePath)
    moduleName = @normalizeName(compilePath)

    try
      # Pass 0
      content = data

      # Pass 1: compile emblem
      content = Emblem.compile(content) if extension is '.emblem'

      # Pass 2: compile htmlbars
      content = @htmlbarsCompiler.precompile(content, false)

      result = "module.exports = Ember.HTMLBars.template(#{content});"
    catch err
      error = err + "#{compilePath}"
    finally
      callback error, result

