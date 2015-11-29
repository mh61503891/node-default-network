# default-network

A Node.js module to get **default gateway** and **default interface**.

100% Pure Java**Script**😽

This module depends on following commands by using [chid_process](https://nodejs.org/api/child_process.html) provided by Node.js.

- win32
	- `wmic path Win32_NetworkAdapterConfiguration get *`
	- `wmic path Win32_NetworkAdapter get *`
- darwin
    - `route -n get -inet default`
    - `route -n get -inet6 default`
- linux
    - `route -n -A inet`
    - `route -n -A inet6`

## Installation

```bash
npm install default-network
```

## API

### collect(callback)

Asynchronously collects a object which contains interface names, families (IPv4 or IPv6), and addresses. The `callback` gets two arguments `(error, data)`.

#### Example 1

How to get default gateway and default interface.

An example code: `example1.js`

```js
var route = require('default-network');
route.collect(function(error, data) {
  console.log(data);
});
```

An example output:

```js
{ en0: 
   [ { family: 'IPv4', address: '192.168.1.1' },
     { family: 'IPv6', address: 'fe80::20b:a2ff:fede:2886%en0' } ] }
```

#### Example 2

How to get default interface from `os.networkInterfaces()`.

An example code: `example2.js`

```js
var os = require('os');
var route = require('default-network');
route.collect(function(error, data) {
  names = Object.keys(data);
  console.log(os.networkInterfaces()[name[0]]);
});
```

An example output:

```js
[ { address: '192.168.1.6',
    netmask: '255.255.255.0',
    family: 'IPv4',
    mac: '00:00:00:00:00:00',
    internal: false },
  { address: 'fe80::3636:3bff:fece:d106',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 4,
    internal: false },
  { address: '2001:a0ae:7c22:0:3636:3bff:fece:d106',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 0,
    internal: false },
  { address: '2001:a0ae:7c22:0:2994:aeb5:5973:5cd4',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 0,
    internal: false } ]
```

## Development

### Test

```bash
npm test
```

or

```bash
./node_modules/.bin/gulp test
```

or

```bash
./node_modules/.bin/mocha
```

## Author

Masayuki Higashino

## License

The MIT License
