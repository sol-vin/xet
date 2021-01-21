get "/api/targets/add_from_found/:ip" do |env|
  begin
    host_ip = env.params.url["ip"]
    if net_com_reply = XET::App::FoundDevices[host_ip]?
      target = XET::App::Target.new("New Camera#{host_ip.hash}")
      target.config = net_com_reply.config
      
      Log.info {"Added target! #{host_ip}"} if XET::App::Targets.add?(target)
    end
  rescue exception
    
  end
  env.redirect "/"
end

post "/api/targets/add" do |env|
  puts env.params.body.to_s
  begin
    if name = env.params.body["name"]?
      target = XET::App::Target.new(name)
      if host_ip = env.params.body["ip"]?
        target.config.host_ip = ::Socket::IPAddress.new(host_ip, 0)
      end

      if mac = env.params.body["mac"]?
        target.config.mac = mac
      end

      if sn = env.params.body["sn"]?
        target.config.serial_number = sn
      end

      if http_port = env.params.body["httpport"]?
        target.config.http_port = http_port.to_u16
      end

      if tcp_port = env.params.body["tcpport"]?
        target.config.tcp_port = tcp_port.to_u16
      end

      if udp_port = env.params.body["udpport"]?
        target.config.udp_port = udp_port.to_u16
      end
      
      if discovery_port = env.params.body["discport"]?
        target.discovery_port = discovery_port.to_u16
      end
      XET::App::Targets.add?(target)
    end
  rescue e
    Log.error {"Targets API Error: #{e.to_s}"}
  end
  env.redirect "/"
end


get "/api/targets/delete/:name" do |env|
  begin
    name = HTML.unescape env.params.url["name"]
    XET::App::Targets.delete(name)
    Log.info {"Deleted target! #{name}"}
  rescue exception
    
  end
  env.redirect "/"
end