require "io"
require "json"
require "socket"
require "uuid"

require "./xet/errors"
require "./xet/info/**"
require "./xet/macros/**"

require "./xet/message"
require "./xet/socket"
require "./xet/commands/**"

module XET
  VERSION                = {{ `shards version #{__DIR__}`.chomp.stringify }}
  DEFAULT_TCP_PORT       = 34567_u16
  DEFAULT_UDP_PORT       = 34568_u16
  DEFAULT_DISCOVERY_PORT = 34569_u16
end
