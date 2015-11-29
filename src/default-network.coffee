platform = require('os').platform()
api = switch platform
  when 'win32'  then require('./api-win32')
  when 'darwin' then require('./api-darwin')
  when 'linux'  then require('./api-linux')
  else -> callback(null, {} )
module.exports =
  collect: api.collect
