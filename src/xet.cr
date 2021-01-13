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
  DEFAULT_TCP_PORT       = 34567
  DEFAULT_UDP_PORT       = 34568
  DEFAULT_DISCOVERY_PORT = 34569
end
