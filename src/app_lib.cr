require "interface_address"
require "./xet"

require "./app/macros/**"
require "./app/target"
require "./app/targets"
require "./app/found_devices"
require "./app/broadcaster"
require "./app/broadcasters"

module XET::App
  class_getter interface = ARGV[1]? || ""
  class_property broadcast_ip = ::Socket::IPAddress::BROADCAST
  class_property server_ip = ::Socket::IPAddress::UNSPECIFIED
end


if ARGV[1]?
  ifs = InterfaceAddress.get_interface_addresses.select { |i| i.interface_name == "enp3s0" && i.ip_address.family.inet? }
  if ifs.size == 1
    XET::App.server_ip = ifs[0].ip_address.address

    # We we change the server IP we also need to change the broadcast
    # ip_split = ifs[0].ip_address.address.split(".")
    # XET::App.broadcast_ip = "#{ip_split[0]}.#{ip_split[1]}.#{ip_split[2]}.255"
  else
    # Do nothing, we already have an unspecified IPAddress
  end
end
