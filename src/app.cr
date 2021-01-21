require "kemal"
require "fiberpool"
require "redis"

require "./app_lib"
require "./app/routes/**"


# Add default broadcaster
XET::App::Broadcasters[XET::DEFAULT_DISCOVERY_PORT] = XET::App::Broadcaster.new(XET::DEFAULT_DISCOVERY_PORT)
XET::App::Broadcasters[XET::DEFAULT_DISCOVERY_PORT].start_listening


Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run
