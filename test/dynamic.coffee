async = require 'async'
should = require('chai').should()
rack = require '../.'
express = require 'express'
easyrequest = require 'request'
fs = require 'fs'
{join} = require 'path'

class CustomAsset extends rack.Asset
    create: (options) ->
        @emit 'created', contents: fs.readFileSync options.filename

describe 'a dynamic asset builder', ->
    app = null
    server = null
    fixturesDir = join __dirname, 'fixtures'

    beforeEach ->
        app = express()

    it 'should work with any custom asset that takes filename option', (done) ->
        app.use new rack.DynamicAssets
            type: CustomAsset
            urlPrefix: '/static'
            dirname: join fixturesDir, 'static'
        server = app.listen 7076, ->
            async.parallel [
                (next) ->
                    easyrequest 'http://localhost:7076/static/blank.txt', (error, response, body) ->
                        response.headers['content-type'].should.equal 'text/plain'
                        body.should.equal fs.readFileSync join(fixturesDir, 'static/blank.txt'), 'utf8'
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/static/crazy-man.svg', (error, response, body) ->
                        response.headers['content-type'].should.equal 'image/svg+xml'
                        body.should.equal fs.readFileSync join(fixturesDir, 'static/crazy-man.svg'), 'utf8'
                        next()
            ], done

    it 'should work with a rack', (done) ->
        app.use new rack.Rack [
            new rack.DynamicAssets
                type: CustomAsset
                urlPrefix: '/static'
                dirname: join fixturesDir, 'static'
        ]
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/static/blank.txt', (error, response, body) ->
                body.should.equal fs.readFileSync join(fixturesDir, 'static/blank.txt'), 'utf8'
                done()

    it 'should work with no urlPrefix option', (done) ->
        app.use new rack.DynamicAssets
            type: CustomAsset
            dirname: join fixturesDir, 'static'
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/blank.txt', (error, response, body) ->
                response.statusCode.should.equal 200
                done()

    it 'should work with options option', (done) ->
        app.use new rack.DynamicAssets
            type: CustomAsset
            dirname: join fixturesDir, 'static'
            options:
                mimetype: 'text/css'
        server = app.listen 7076, ->
            easyrequest 'http://localhost:7076/blank.txt', (error, response, body) ->
                response.headers['content-type'].should.equal 'text/css'
                done()

    it 'should work with a filter', (done) ->
        app.use new rack.Rack [
            new rack.DynamicAssets
                type: CustomAsset
                urlPrefix: '/string-filter'
                dirname: join fixturesDir, 'static'
                filter: 'txt'
            new rack.DynamicAssets
                type: CustomAsset
                urlPrefix: '/function-filter'
                dirname: join fixturesDir, 'static'
                filter: (file) -> file.ext is '.svg'
        ]
        server = app.listen 7076, ->
            async.parallel [
                (next) ->
                    easyrequest 'http://localhost:7076/string-filter/blank.txt', (error, response, body) ->
                        response.statusCode.should.equal 200
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/string-filter/crazy-man.svg', (error, response, body) ->
                        response.statusCode.should.equal 404
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/function-filter/blank.txt', (error, response, body) ->
                        response.statusCode.should.equal 404
                        next()
                (next) ->
                    easyrequest 'http://localhost:7076/function-filter/crazy-man.svg', (error, response, body) ->
                        response.statusCode.should.equal 200
                        next()
            ], done

    afterEach (done) -> process.nextTick ->
        server.close done
