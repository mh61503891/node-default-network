net = require('net')
exec = require('child_process').exec

getDefaultNetwork = (command, callback) ->
  exec command, (error, stdout, stderr) ->
    return callback(error) if error?
    return callback(new Error(stderr.trim())) if stderr.trim() != ''
    return callback(null, new Object) if stdout.trim() == ''
    data = {}
    stdout = stdout.trim()
    for line in stdout.split('\n')
      [defaultGateway, defaultInterface] = line.split(' ')
      if not defaultGateway? || not defaultInterface?
        return callback(new Error("parse error: #{stdout}"))
      if not net.isIP(defaultGateway)
        return callback(new Error("parse error: #{stdout}"))
      data[defaultInterface] || = []
      family = switch net.isIP(defaultGateway)
        when 4 then 'IPv4'
        when 6 then 'IPv6'
      if not family?
        return callback(new Error("invalid address: #{stdout}"))
      data[defaultInterface].push {
        family: family
        address: defaultGateway
      }
    callback(null, data)

getDefaultNetworkByInet4 = (callback) ->
  getDefaultNetwork "netstat -rn -f inet | awk '$3~/UG/ {print $2,$6;}'",
    (error, data) ->
      callback(error, data)

getDefaultNetworkByInet6 = (callback) ->
  getDefaultNetwork "netstat -rn -f inet6 | awk '$3~/UG/ {print $2,$4;}'",
    (error, data) ->
      callback(error, data)

collect = (callback) ->
  getDefaultNetworkByInet4 (error4, data4) ->
    getDefaultNetworkByInet6 (error6, data6) ->
      result = {}
      for data in [data4, data6]
        for iface, adapters of data
          result[iface] || = []
          result[iface].push(adapters...)
      # collect() does not return errors
      callback(null, result)

module.exports =
  collect: collect
