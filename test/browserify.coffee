
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

describe 'a browserify asset', ->
    app = null
    server = null
    fixturesDir = "#{__dirname}/fixtures/browserify"

    beforeEach ->
        app = express()

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/app.js", 'utf8'
        app.use new rack.BrowserifyAsset {
            filename: "#{fixturesDir}/sample.js"
            url: '/app.js'
        }
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript; charset=utf-8'
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{fixturesDir}/app.min.js", 'utf8'
        app.use asset = new rack.BrowserifyAsset
            filename: "#{fixturesDir}/sample.js"
            url: '/app.js'
            compress: true
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/app.js', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/javascript; charset=utf-8'
                done()

    #it 'should work with extension handlers', (done) ->
    #    done()

    #it 'should work with debug option', (done) ->
    #    done()


    afterEach (done) -> process.nextTick ->
        server.close done
