
# Index.coffee - Entry point puts all the code together

exports.Asset = require('./asset').Asset
exports.Rack = require('./rack').Rack
exports.fromConfigFile = require('./rack').fromConfigFile
exports.AssetRack = require('./rack').Rack # backwards compatibility with 1.x
exports.DynamicAssets = require('./modules/dynamic').DynamicAssets
exports.LessAsset = require('./modules/less').LessAsset
exports.BrowserifyAsset = require('./modules/browserify').BrowserifyAsset
exports.StaticAssets = require('./modules/static').StaticAssets

util = require './util'
exports.util =
  walk: util.walk
