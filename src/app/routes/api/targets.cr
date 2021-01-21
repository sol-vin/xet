get "/api/targets/add_from_found/:ip" do |env|
  begin
    ip = env.params.url["ip"]
    if net_com_reply = XET::App::FoundDevices[ip]?
      target = XET::App::Target.new("New Camera#{ip.hash}")
      target.config = net_com_reply.config
      
      XET::App::Targets.add?(target)
      Log.info {"Added target! #{ip}"}
    end
  rescue exception
    
  end
  env.redirect "/"
end

post "/api/targets/add" do |env|
  puts env.params.body.to_s
  env.redirect "/"
end

get "/api/targets/add" do |env|
  render_page("add_target")
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