# default-network

A Node.js module to get **default gateway** and **default interface**.

100% Pure Java**Script**😽

This module depends on following commands by using [chid_process](https://nodejs.org/api/child_process.html) provided by Node.js.

- win32
	- `wmic path Win32_NetworkAdapterConfiguration get *`
	- `wmic path Win32_NetworkAdapter get *`
- darwin
    - `netstat -rn -f inet`
    - `netstat -rn -f inet6`
- linux
    - `netstat -rn -A inet`
    - `netstat -rn -A inet6`

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
{ en4: 
   [ { family: 'IPv4', address: '192.168.1.1' },
     { family: 'IPv6', address: 'fe80::20b:a2ff:fede:2886%en4' } ],
  en0: 
   [ { family: 'IPv4', address: '192.168.1.1' },
     { family: 'IPv6', address: 'fe80::20b:a2ff:fede:2886%en0' } ],
  en8: 
   [ { family: 'IPv4', address: '192.168.1.1' },
     { family: 'IPv6', address: 'fe80::20b:a2ff:fede:2886%en8' } ] }
```

#### Example 2

How to get default interface from `os.networkInterfaces()`.

An example code: `example2.js`

```js
var os = require('os');
var route = require('default-network');
route.collect(function(error, data) {
  names = Object.keys(data);
  // names[0] is 'en4'
  console.log(os.networkInterfaces()[names[0]]);
});
```

An example output:

```js
[ { address: 'fe80::6a5b:35ff:fe96:cc05',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 14,
    internal: false },
  { address: '2001:a0ae:7c22:0:6a5b:35ff:fe96:cc05',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 0,
    internal: false },
  { address: '2001:a0ae:7c22:0:a8d1:fef3:2917:cd87',
    netmask: 'ffff:ffff:ffff:ffff::',
    family: 'IPv6',
    mac: '00:00:00:00:00:00',
    scopeid: 0,
    internal: false },
  { address: '192.168.1.10',
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
