# Xiongmai Exploitation Toolkit

### WARNING! THIS TOOL IS FOR EDUCATIONAL PURPOSES, IF YOU USE THIS TOOLKIT TO BE AN ASS YOU WILL GET SUED BY SOMEONE AND I WILL LAUGH AT HOW DUMB YOU ARE.

We live in a world dominated by cheap, poorly designed products. Many are designed that way for many different reasons; planned obsolescence, consumer spying, or even more nefarious, governmental spying. For decades China has been the seller of cheap and knock off goods, and they've slowly cornered the market due to a companies natural desire to keep costs low, even sacrificing quality in the process. The result is terrifying for those who understand what that control can mean. After being caught up in a mass attack against their camera products, the Xiongmai company, controlled and owned by the Chinese government, got caught attacking their own cameras and decided to attempt to [cover up the Mirai botnet attacks](https://ipvm.com/reports/xiongmai-threaten). Their products are insecure, dangerous, and downright malicious. While consumers are more aware of their products, the problem has taken on a new seedy undertone. Xiongmai has been selling and rebranding their cameras to third party companies which then hawk the products on Amazon, Wish, etc. While this is incredibly dangerous to consumers who don't know any better, this presents an interesting challenge and opportunity to learn stronger hacking skills.

This toolkit provides a set of tools used to work with these cameras, for fun and learning!

## Library

XET is a library that can be used by Crystal to interact with the cameras programatically.

### Usage
```
dependencies:
  xet:
    github: redcodefinal/xet
```

then

```crystal
require "xet"
```

#### Docs

Will be available at some point in the future when I figure out how to properly document the macros I used :(

## Tools

### Implemented
 - :(
### Coming Soon
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

## Cameras

You can use this toolkit with any camera that uses the `XMEye` android app. Be careful about installing that one because it as well is very dangerous potentially stealing your information.

Recently I bought these:
 - [Eversecu Security Camera](https://www.amazon.com/gp/product/B07GPGPV67/ref=ppx_yo_dt_b_asin_title_o05_s00?ie=UTF8&psc=1) Mostly because they are POE and easy to turn on and off with a Cisco switch.

## Run the Web App

```
shards install
shards build app
./bin/app
```

## Contributors

- [Ian Rash](https://github.com/redcodefinal) - creator and maintainer
