# default-network

A Node.js module to get **default gateway** and **default interface**.

The value from the callback function `get()` is depend on following commands by using [chid_process](https://nodejs.org/api/child_process.html) provided by Node.js.

- win32
	- `wmic path Win32_NetworkAdapterConfiguration get *`
	- `wmic path Win32_NetworkAdapter get *`
- darwin: `route -n get default`
- linux: `route -n`

## API

### get(callback)

Asynchronously gets a object which contains `defaultGateway` and `defaultInterface`. The `callback` gets two arguments `(error, data`).

#### Example 1

How to get default gateway and default interface.

An example code: `example1.coffee`

```coffee
# written in CoffeeScript
route = require('default-network')
route.get (error, data) ->
  console.log(data)
```

An example output:

```coffee
{ defaultGateway: '192.168.1.1', defaultInterface: 'en0' }
```

#### Example 2

How to get default interface from `os.networkInterfaces()`.

An example code: `example2.coffee`

```coffee
# written in CoffeeScript
os = require('os')
route = require('default-network')
route.get (error, data) ->
  console.log(os.networkInterfaces()[data.defaultInterface])
```

An example output:

```coffee
[ { address: '2001:db8::',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 4,
    internal: false },
  { address: '192.0.2.0',
    netmask: '255.255.255.0',
    family: 'IPv4',
    mac: '00:00:00:00:00:00',
    internal: false } ]
```

## Development

### Test

```bash
npm test
```

or

```bash
node_modules\.bin\gulp test
```

or

```bash
node_modules\.bin\mocha
```

## Author

- Masayuki Higashino

## License

The MIT License
