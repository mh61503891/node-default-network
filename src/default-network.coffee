parseCSV = require('csv-parse')
exec = require('child_process').exec

getOnWin32 = (callback) ->

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
        return callback(error) if error
        callback(null, records)

  getAdapterConfigs = (callback) ->
    wmic 'Win32_NetworkAdapterConfiguration',
      ['Index', 'IPEnabled', 'DefaultIPGateway'], (error, records) ->
        return callback(error) if error
        callback(null, records)

  getAdapters = (callback) ->
    wmic 'Win32_NetworkAdapter',
      ['Index', 'NetConnectionID'], (error, records) ->
        return callback(error) if error
        callback(null, records)

  getDefaultGateway = (callback) ->
    getAdapterConfigs (error, records) ->
      return callback(error) if error
      for record in records
        continue if record['IPEnabled'] != 'TRUE'
        continue if record['DefaultIPGateway'] == ''
        index = parseInt(record['Index'])
        defaultGateway = (record['DefaultIPGateway']||'')
        defaultGateway = ((defaultGateway.match(/{(.*)}/) ||[])[1]||'')
        defaultGateway = defaultGateway.split(/\s+/)[0]
        return callback null, {
          index: index
          defaultGateway: defaultGateway
        }
      callback(new Error('default gateway is not available'))

  getInterface = (index, callback) ->
    getAdapters (error, records) ->
      return callback(error) if error
      for record in records
        if parseInt(record['Index']) == index
          return callback(null, record['NetConnectionID'])
      callback(new Error("inteface #{index} is not available"))

  getDefaultGateway (error, config) ->
    return callback(error) if error
    getInterface config.index, (error, data) ->
      return callback(error) if error
      result = {}
      result.defaultGateway = config.defaultGateway
      result.defaultInterface = data
      callback(null, result)

getOnDarwin = (callback) ->
  exec 'route -n get default', (error, stdout, stderr) ->
    return callback(error) if error
    defaultGateway = (stdout.match(/gateway:\s*(.+)\s*\n/) || [])[1]
    defaultInterface = (stdout.match(/interface:\s*(.+)\s*\n/) || [])[1]
    data = {}
    data.defaultGateway = defaultGateway if defaultGateway?
    data.defaultInterface = defaultInterface if defaultInterface?
    callback(null, data)

getOnLinux = (callback) ->
  childProcess = require('child_process')
  childProcess.exec '/sbin/route -n', (error, stdout, stderr) ->
    return callback(error) if error
    line = (stdout.match(/(^0.0.0.0.*\n)/m) ||[])[1].split(/\s+/)
    defaultGateway = line[1]
    defaultInterface = line[7]
    data = {}
    data.defaultGateway = defaultGateway if defaultGateway?
    data.defaultInterface = defaultInterface if defaultInterface?
    callback(null, data)

getOnDefault = (callback) ->
  data = {
  }
  callback(null, data)

get = (callback) ->
  platform = require('os').platform()
  collector = switch platform
    when 'win32'
      getOnWin32
    when 'darwin'
      getOnDarwin
    when 'linux'
      getOnLinux
    else
      getOnDefault
  collector (error, data) -> callback(error, data)

module.exports =
  get: get
