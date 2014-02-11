fs = require 'fs'
pathutil = require 'path'
browserify = require 'browserify'
uglify = require('uglify-js')
Asset = require('../index').Asset

class exports.BrowserifyAsset extends Asset
    mimetype: 'text/javascript'

    create: (options) ->
        @filename = options.filename
        @toWatch = pathutil.dirname pathutil.resolve @filename
        @require = options.require
        @debug = options.debug or false
        @compress = options.compress
        @compress ?= false
        @extensionHandlers = options.extensionHandlers or []
        agent = browserify watch: false, debug: @debug
        for handler in @extensionHandlers
            agent.register(handler.ext, handler.handler)
        agent.add @filename
        agent.require @require if @require

        agent.bundle (err, js) =>
          if @compress
            contents = uglify.minify(js, { fromString: true }).code
          else
            contents = js

          @emit 'created', contents: contents
