alias IString = (String | Int32)
require "io"
require "json"
require "socket"
require "uuid"
require "log"

require "./xet/errors"
require "./xet/ipaddress"
require "./xet/session_id"

require "./xet/info/**"
require "./xet/macros/**"

require "./xet/hash"
require "./xet/message"

require "./xet/commands"

require "./xet/commands/templates/**"

require "./xet/commands/bits"
require "./xet/commands/login"
require "./xet/commands/network"
require "./xet/commands/operation"
require "./xet/commands/systeminfo"

require "./xet/socket"

module XET
  VERSION                = {{ `shards version #{__DIR__}`.chomp.stringify }}
  DEFAULT_HTTP_PORT      = 80_u16
  DEFAULT_TCP_PORT       = 34567_u16
  DEFAULT_UDP_PORT       = 34568_u16
  DEFAULT_DISCOVERY_PORT = 34569_u16
end
