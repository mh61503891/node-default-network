net = require('net')
exec = require('child_process').exec

getDefaultRoute = (family, callback) ->
  exec "route -n get #{family} default", (error, stdout, stderr) ->
    unless family == '-inet' or family == '-inet6'
      return callback(new Error("unsupported family option: #{family}"))
    return callback(error) if error?
    return callback(new Error(stderr.trim())) if stderr != ''
    defaultGateway = (stdout.match(/gateway:\s*(.+)\s*\n/) || [])[1]
    defaultInterface = (stdout.match(/interface:\s*(.+)\s*\n/) || [])[1]
    if not defaultGateway? || not defaultInterface?
      return callback(new Error('defaultGateway or defaultInterface not found'))
    if not net.isIP(defaultGateway)
      return callback(new Error("defaultGateway not found: #{defaultGateway}"))
    data = {
      defaultGateway: defaultGateway
      defaultInterface: defaultInterface
    }
    callback(error, data)

getDefaultRouteByInet4 = (callback) ->
  getDefaultRoute '-inet', (error, data) ->
    callback(error, data)

getDefaultRouteByInet6 = (callback) ->
  getDefaultRoute '-inet6', (error, data) ->
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

module.exports =
  collector: collector
