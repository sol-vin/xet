require "kemal"
require "fiberpool"
require "redis"

require "./xet"

require "./app/macros/**"

Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run
