get = (callback) ->
  platform = require('os').platform()
  collector = switch platform
    when 'win32'  then require('./collector-win32').collector
    when 'darwin' then require('./collector-darwin').collector
    when 'linux'  then require('./collector-linux').collector
    else -> callback(new Error("unsupported platform: #{platform}"))
  collector (error, data) -> callback(error, data)

module.exports =
  get: get
