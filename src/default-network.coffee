get = (callback) ->
  platform = require('os').platform()
  collector = switch platform
    when 'win32'
      require('./win32').collector
    when 'darwin'
      require('./darwin').collector
    when 'linux'
      require('./linux').collector
    else
      -> callback(new Error("unsupported platform: #{platform}"))
  collector (error, data) -> callback(error, data)

module.exports =
  get: get
