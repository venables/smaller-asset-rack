
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'

describe 'a less asset', ->
    app = null
    server = null

    beforeEach ->
        app = express()

    it 'should work', (done) ->
        compiled = fs.readFileSync "#{__dirname}/fixtures/less/simple.css", 'utf8'

        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/less/simple.less"
            url: '/style.css'
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css; charset=utf-8'
                body.should.equal compiled
                done()

    it 'should work compressed', (done) ->
        compiled = fs.readFileSync "#{__dirname}/fixtures/less/simple.min.css", 'utf8'

        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/less/simple.less"
            url: '/style.css'
            compress: true
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css; charset=utf-8'
                body.should.equal compiled.replace(/\n*$/, '')
                done()

    it 'should work with paths', (done) ->
        compiled = fs.readFileSync "#{__dirname}/fixtures/less/another.css", 'utf8'

        app.use new rack.LessAsset
            filename: "#{__dirname}/fixtures/less/another.less"
            url: '/style.css'
            paths: ["#{__dirname}/fixtures/less/more"]
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css; charset=utf-8'
                body.should.equal compiled
                done()

    it 'should work with the rack', (done) ->
        app.use assets = new rack.AssetRack [
            new rack.Asset
                url: '/background.png'
                contents: 'not a real png'
            new rack.LessAsset
                filename: "#{__dirname}/fixtures/less/simple.less"
                url: '/simple.css'
            new rack.LessAsset
                filename: "#{__dirname}/fixtures/less/dependency.less"
                url: '/style.css'
        ]
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/style.css', (error, response, body) ->
                backgroundUrl = assets.url('/background.png')
                body.indexOf(backgroundUrl).should.not.equal -1
                done()

    it.skip 'should throw a meaningful error', (done) ->
        should.Throw ->
            app.use assets = new rack.AssetRack [
                asset = new rack.LessAsset
                    filename: "#{__dirname}/fixtures/less/syntax-error.less"
                    url: '/style.css'
            ]
        should.Throw ->
            app.use assets = new rack.AssetRack [
                asset = new rack.LessAsset
                    contents : """
                    @import "file-that-doesnt-exist.less";
                    body {
                        background-color: blue;
                        div {
                          background-color: pink;
                        }
                    }
                    """
                    url: 'style.css'
            ]

        # just start a server so that `afterEach` can close it without issues

        server = app.listen 7076, ->
            done()

    afterEach (done) -> process.nextTick ->
        server.close done
