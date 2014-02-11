
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

describe 'a static asset builder', ->
    app = null
    server = null

    beforeEach ->
        app = express()

    it 'should work', (done) ->
        staticPath = "#{__dirname}/fixtures/static"
        compiled = fs.readFileSync "#{staticPath}/blank.txt", 'utf8'
        app.use new rack.StaticAssets
            dirname: staticPath
            urlPrefix: '/static'
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/static/blank.txt', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/plain'
                body.should.equal compiled
                done()

    afterEach (done) -> process.nextTick ->
        server.close done
