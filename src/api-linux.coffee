net = require('net')
exec = require('child_process').exec
async = require('async')

getRouteCommandPath = (callback) ->
  paths = [
    'route',
    '/sbin/route' # for Debian
  ]
  async.detect paths,
    (path, callback) ->
      exec "which #{path}", (error, stdout, stderr) ->
        callback not error?
    (path) ->
      if not path?
        error = new Error("route command not found: paths #{paths.join(', ')}")
        return callback(error)
      callback(null, path)

getDefaultRouteByInet4 = (path, callback) ->
  exec "#{path} -n -A inet | awk '$4~/UG/ {print $2,$8;}'",
    (error, stdout, stderr) ->
      return callback(error) if error?
      return callback(new Error(stderr.trim())) if stderr.trim() != ''
      [defaultGateway, defaultInterface] = stdout.trim().split(' ')
      if not defaultGateway? || not defaultInterface?
        return callback(new Error("UG not found"))
      data = {
        defaultGateway: defaultGateway
        defaultInterface: defaultInterface
      }
      callback(null, data)

getDefaultRouteByInet6 = (path, callback) ->
  exec "#{path} -n -A inet6 | awk '$3~/UG/ {print $2,$7;}'",
    (error, stdout, stderr) ->
      return callback(error) if error?
      return callback(new Error(stderr.trim())) if stderr.trim() != ''
      [defaultGateway, defaultInterface] = stdout.trim().split(' ')
      if not defaultGateway? || not defaultInterface?
        return callback(new Error("UG not found"))
      data = {
        defaultGateway: defaultGateway
        defaultInterface: defaultInterface
      }
      callback(null, data)

collect = (callback) ->
  getRouteCommandPath (error, path) ->
    getDefaultRouteByInet4 path, (error4, data4) ->
      getDefaultRouteByInet6 path, (error6, data6) ->
        data = {}
        if data4?
          data[data4.defaultInterface] || = []
          data[data4.defaultInterface].push {
            family: 'IPv4'
            address: data4.defaultGateway
          }
        if data6?
          data[data6.defaultInterface] || = []
          data[data6.defaultInterface].push {
            family: 'IPv6'
            address: data6.defaultGateway
          }
        callback(null, data)

module.exports =
  collect: collect
