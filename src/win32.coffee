net = require('net')
parseCSV = require('csv-parse')
exec = require('child_process').exec
async = require('async')

wmic = (cls, keys, callback) ->
  command = "wmic path #{cls} get #{keys.join(',')} /format:csv"
  exec command, (error, stdout, stderr) ->
    return callback(error) if error
    parseCSV stdout, {
      columns: true
      rowDelimiter: '\r\r\n'
      skip_empty_lines: true
      trim: true
    } , (error, records) ->
      callback(error, records)

getOnWin32 = (callback) ->

  getAdapterConfigs = (callback) ->
    wmic 'Win32_NetworkAdapterConfiguration',
      ['Index', 'IPEnabled', 'DefaultIPGateway'], (error, records) ->
        callback(error, records)

  getAdapters = (callback) ->
    wmic 'Win32_NetworkAdapter',
      ['Index', 'NetConnectionID'], (error, records) ->
        callback(error, records)

  getDefaultGateway = (callback) ->
    getAdapterConfigs (error, records) ->
      return callback(error) if error
      data = {}
      for record in records
        continue if not record['IPEnabled']?
        continue if not record['DefaultIPGateway']?
        continue if not record['Index']?
        continue if record['IPEnabled'] != 'TRUE'
        continue if record['DefaultIPGateway'].trim() == ''
        continue if isNaN(parseInt(record['Index']))
        index = record['Index']
        defaultGateway = record['DefaultIPGateway'].trim()
        defaultGateway = ((defaultGateway.match(/{(.*)}/) || [])[1] || '')
        for address in defaultGateway.split(';')
          switch net.isIP(address)
            when 4
              data[index] || = []
              data[index].push {family: 'IPv4', address: address}
            when 6
              data[index] || = []
              data[index].push {family: 'IPv6', address: address}
      callback(error, data)

  getInterface = (index, callback) ->
    getAdapters (error, records) ->
      return callback(error) if error
      for record in records
        if record['Index'] == index
          return callback(null, record['NetConnectionID'])
      callback(new Error("inteface #{index} is not available"))

  getDefaultGateway (error, config) ->
    return callback(error) if error
    indexes = Object.keys(config)
    async.map indexes,
      (index, callback) ->
        getInterface index, (error, iface) ->
          callback(error, {index: index, iface: iface} )
      (error, list) ->
        data = {}
        for e in list
          data[e.iface] = config[e.index]
        callback(null, data)

module.exports =
  collector: getOnWin32