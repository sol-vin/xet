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

You can also get access to some of the features of the web app by using

```crystal
require "xet/app"
```

#### Docs

Will be available at some point in the future when I figure out how to properly document the macros I used :(

## Cli

You can use the CLI by compiling `xet` and then using the commands built in.

#### info

You can view certain informational pieces by using the `info` command. Things like, known command ids, bad command ids, and known ret codes.

#### msg 

Using `msg` you can print a message as a string to easily insert into programs. For example:

Using `xet msg` will produce a blank message:
```
'\xFF\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000'
```

Using `xet msg -w [template name]` allows you to specify a template to use as a base.

`xet msg -w System::Info::Request`
```
'\xFF\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\xFC\u0003.\u0000\u0000\u0000{\"Name\":\"SystemInfo\",\"SessionID\":\"0x00000000\"}'
```

You can also change various fields using the arguments. Any field argument listed below (besides `--message`) allow for you to use decimal (`123`), hexadecimal (`0x123`) or binary (`0b110011`) numbers.

`xet msg --type 0b01 --version 2 --reserved1 3 --reserved2 0x4 --session_id 0x05060708 --sequence 0x090A0B0C --total_packets 0x0d --current_packet 0x0e --id 0x0f10 --size 0x11121314 --message ZYXWV`

```
'\u0001\u0002\u0003\u0004\b\a\u0006\u0005\f\v\n\t\r\u000E\u0010\u000F\u0014\u0013\u0012\u0011ZYXWV'
```

Using these arguments with the template `-w` command allows for quick building of messages.

#### send
`send` allows you to send a message to a device and, also allows the user to listen to a reply. 

`xet send [options] [ip]`

Some exmaples.

Login to a camera and get it's info
`xet send --template System::Info::Reply [ip]`

[![asciicast](https://asciinema.org/a/8bOJwkEf9EEGvDDIlLhzHcuXH.svg)](https://asciinema.org/a/8bOJwkEf9EEGvDDIlLhzHcuXH)

Try a command without authenticating first

`xet send --no-login --template Login::Request [ip]`

[![asciicast](https://asciinema.org/a/2RvDnKsByUqSFt1WrPfZqKHCk.svg)](https://asciinema.org/a/2RvDnKsByUqSFt1WrPfZqKHCk)

Perform a broadcast and listen for multiple replies

`xet send --no-login --listen 2 --template Network::Common::Request --port 34569 --connection udp --bind [interface] [broadcast ip]`

[![asciicast](https://asciinema.org/a/KSGqQQr2jp03ah56KQYeeXGod.svg)](https://asciinema.org/a/KSGqQQr2jp03ah56KQYeeXGod)

You can also change the fields like in `msg` using `--type`, `--version`, etc, etc.

## Run the Web App

```
shards install
shards build xet
xet web --port [port] --interface [if]
```

### Implemented
 - Broadcaster
   - You can now broadcast and find devices.
### Coming Soon
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



## Contributors

- [Ian Rash](https://github.com/redcodefinal) - creator and maintainer
