require "kemal"
require "fiberpool"
require "redis"

require "./xet"

require "./app/macros/**"
require "./app/routes/**"
require "./app/target"
require "./app/targets"
require "./app/broadcaster"
require "./app/broadcasters"


module XET::App
end

# Add default broadcaster
XET::App::Broadcasters[XET::DEFAULT_DISCOVERY_PORT] = XET::App::Broadcaster.new(XET::DEFAULT_DISCOVERY_PORT)
XET::App::Broadcasters[XET::DEFAULT_DISCOVERY_PORT].start_listening

Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run
