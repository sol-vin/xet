module IPAddr
  enum INetType
    IPV4
    IPV6
  end

  record Interface, name : String, ip : String, mac : String, inet_type : INetType, broadcast_ip : String, broadcast_mac : String, netmask_bits : UInt8

  def self.get_interface(i_name : String, inet_type = INetType::IPV4) : Interface
    ip_addr_output = `ip addr show dev #{i_name}`
    raise "DEVICE #{i_name} NOT FOUND" if ip_addr_output =~ /Device \".+\" does not exist\./

    mac = ""
    broadcast_mac = ""
    match_data = ip_addr_output.lines[1]?.try(&.match(/link\/ether (.{17}).*brd.(.{17})/))
    if match_data
      mac = match_data.try(&.[1])
      broadcast_mac = match_data.try(&.[2])
    end

    ip = ""
    broadcast_ip = ""
    netmask_bits = 0_u8
    if inet_type == INetType::IPV4
      match_data = ip_addr_output.lines[2]?.try(&.match(/inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{1,2}) brd (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/))
      if match_data
        ip = match_data.try(&.[1])
        netmask_bits = match_data.try(&.[2]).to_u8
        broadcast_ip = match_data.try(&.[3])
      end
    else
      # TODO: Fix IPV6
      #ip = ip_addr_output.lines[2]?.try(&.match(/inetv6 (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/))[0]
    end



    Interface.new(i_name, ip, mac, inet_type, broadcast_ip, broadcast_mac, netmask_bits)
  end

  def self.get_interfaces(inet_type = INetType.IPV4)
  end
end