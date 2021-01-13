# XET (Xiongmai Exploitation Toolkit)

A toolkit and framework for writing exploits and software around the Xiongmai brand of cameras.

## Installation
### Use as a Library

XET can be used as a library in Crystal.

```crystal
require "xet/xm"
```

### Use as a Web App
XET can be easily used with a web browser.

```
shards install
shards build webapp
./bin/webapp
```

### Use certain individual tools
XET has certain tools which can be broken out into CLI programs.

```crystal
shards install
shards build xmshield # A shield between the vulnerable XM interface, allowing for greater security and use.
```

## Tools
XET comes with a bunch of tools to use

 - Detector
   - Detects Xiongmai products on the network either passively or actively.
 - Packet Inspector
   - Inspects packets
 - Stream Inspector
   - Inspects a stream of packets 
 - Exploit
   - Allows running various exploits with targeting
   - DoS
 - Client
   - An all purpose client for interacting with camera/dvr servers
 - Server
   - An all purpose server which impersonates a camera/dvr
 - MITM
   - Listens for client connections and tries to get between them and the camera/dvr server. 
 - Fuzzing
   - Fuzzs commands and their fields
 - Brute Force
   - Attempts to brute force password hashes
 - Network Brute Force
   - Attempts to brute force via network
 - Fingerprinting
   - Get all settings and information from a client or server.
 - Shield
   - Puts camera's behind a proxy of sorts, allowing them only to communicate with the Shield program, which will implement a safer way of controlling the cameras.

## Commands

A full command structure that involves the complex creation of different commands, their structures, and parsing from `XET::Message`

