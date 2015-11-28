net = require('net')
exec = require('child_process').exec

getDefaultRouteByInet4 = (callback) ->
  exec "/sbin/route -n -A inet | awk '$4~/UG/ {print $2,$8;}'",
    (error, stdout, stderr) ->
      return callback(error) if error?
      return callback(new Error(stderr.trim())) if stderr != ''
      [defaultGateway, defaultInterface] = stdout.trim().split(' ')
      if not defaultGateway? || not defaultInterface?
        return callback(new Error("UG not found"))
      data = {
        defaultGateway: defaultGateway
        defaultInterface: defaultInterface
      }
      callback(error, data)

getDefaultRouteByInet6 = (callback) ->
  exec "/sbin/route -n -A inet6 | awk '$3~/UG/ {print $2,$7;}'",
    (error, stdout, stderr) ->
      return callback(error) if error?
      return callback(new Error(stderr.trim())) if stderr != ''
      [defaultGateway, defaultInterface] = stdout.trim().split(' ')
      if not defaultGateway? || not defaultInterface?
        return callback(new Error("UG not found"))
      data = {
        defaultGateway: defaultGateway
        defaultInterface: defaultInterface
      }
      callback(error, data)

collector = (callback) ->
  getDefaultRouteByInet4 (error4, data4) ->
    getDefaultRouteByInet6 (error6, data6) ->
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

getOnLinux = (callback) ->
  getDefaultRouteByInet6 (error, data) ->
    callback(error, data)

module.exports =
  collector: collector
