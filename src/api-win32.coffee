net = require('net')
exec = require('child_process').exec
async = require('async')
parseXML = require('xml2js').parseString

wmic = (cls, keys, callback) ->
  command = "wmic path #{cls} get #{keys.join(',')} /format:rawxml"
  exec command, (error, stdout, stderr) ->
    return callback(error) if error?
    parseXML stdout, {
      trim: true
      normalize: true
      normalizeTags: true
      mergeAttrs: true
      async: true
    } , (error, result) ->
      records = []
      for r in result.command.results[0].cim[0].instance
        record = {}
        for p in r.property || []
          record[p.NAME] = p.value and p.value[0] or ''
        for p in r['property.array'] || []
          val = p['value.array']
          record[p.NAME] = val and p['value.array'][0].value or ''
        records.push(record)
      callback(error, records)

getAdapterConfig = (callback) ->
  wmic 'Win32_NetworkAdapterConfiguration',
    ['Index', 'IPEnabled', 'DefaultIPGateway'],
    (error, records) ->
      callback(error, records)

getAdapter = (callback) ->
  wmic 'Win32_NetworkAdapter',
    ['Index', 'NetConnectionID'],
    (error, records) ->
      callback(error, records)

getDefaultGateway = (callback) ->
  getAdapterConfig (error, records) ->
    return callback(error) if error?
    data = {}
    for record in records
      continue if not record['IPEnabled']?
      continue if not record['DefaultIPGateway']?
      continue if not record['Index']?
      continue if record['IPEnabled'] != 'TRUE'
      continue if record['DefaultIPGateway'].length == 0
      continue if isNaN(parseInt(record['Index']))
      index = record['Index']
      defaultGateway = record['DefaultIPGateway']
      for address in defaultGateway
        switch net.isIP(address)
          when 4
            data[index] = data[index] || []
            data[index].push {family: 'IPv4', address: address}
          when 6
            data[index] = data[index] || []
            data[index].push {family: 'IPv6', address: address}
          else
            return callback(new Error("#{address} is not IP address"))
    callback(null, data)

getAdapterNameByIndex = (index, callback) ->
  getAdapter (error, records) ->
    return callback(error) if error?
    for record in records
      if record['Index'] == index
        return callback(null, record['NetConnectionID'])
    callback(new Error("inteface #{index} is not available"))

getDefaultNetwork = (callback) ->
  getDefaultGateway (error, gateways) ->
    return callback(error) if error?
    indexes = Object.keys(gateways)
    async.map indexes,
      (index, callback) ->
        getAdapterNameByIndex index, (error, name) ->
          return callback(error) if error?
          iface = {index: index, name: name}
          callback(null, iface)
      (error, ifaces) ->
        return callback(error) if error?
        data = {}
        for iface in ifaces
          data[iface.name] = gateways[iface.index]
        callback(null, data)

collect = (callback) ->
  getDefaultNetwork (error, data) ->
    return callback(null, {} ) if error?
    callback(null, data)

module.exports =
  collect: collect
