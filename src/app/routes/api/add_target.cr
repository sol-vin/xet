get "/api/targets/add_from_found/:ip" do |env|
  begin
    ip = env.params.url["ip"]
    if net_com_reply = XET::App::FoundDevices[ip]?
      target = XET::App::Target.new("New Camera#{ip.hash}")
      target.ip_address = net_com_reply.config.try(&.host_ip).try(&.address)
      target.mac_address = net_com_reply.config.try(&.mac)
      target.serial_number = net_com_reply.config.try(&.serial_number)

      target.tcp_port = net_com_reply.config.try(&.tcp_port)
      target.udp_port = net_com_reply.config.try(&.udp_port)
      target.ssl_port = net_com_reply.config.try(&.ssl_port)
      target.http_port = net_com_reply.config.try(&.http_port)

      XET::App::Targets.add?(target)
      Log.info {"Added target! #{ip}"}
    end
  rescue exception
    
  end
  env.redirect "/"
end