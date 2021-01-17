get "/api/broadcasters/start_listening/:port/" do |env|
  port = env.params.url["port"].to_u16
  bcaster = XET::App::Broadcasters[port]
  unless bcaster.is_listening?
    Log.info { "STARTING LISTENING" }
    bcaster.start_listening
  end
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end

get "/api/broadcasters/stop_listening/:port" do |env|
  port = env.params.url["port"].to_u16
  bcaster = XET::App::Broadcasters[port]
  unless !bcaster.is_listening?
    Log.info { "STOPPING LISTENING" }
    bcaster.stop_listening
  end
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end

get "/api/broadcasters/start_broadcasting/:port" do |env|
  port = env.params.url["port"].to_u16
  bcaster = XET::App::Broadcasters[port]
  unless bcaster.is_broadcasting?
    Log.info { "STARTING BROADCASTING" }
    bcaster.start_broadcasting
  end
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end

get "/api/broadcasters/stop_broadcasting/:port" do |env|
  port = env.params.url["port"].to_u16
  bcaster = XET::App::Broadcasters[port]
  unless !bcaster.is_broadcasting?
    Log.info { "STOPPING BROADCASTING" }
    bcaster.stop_broadcasting
  end
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end

get "/api/broadcasters/delete/:port" do |env|
  port = env.params.url["port"].to_u16
  XET::App::Broadcasters.delete port
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end


get "/api/broadcasters/add/:port" do |env|
  port = env.params.url["port"].to_u16
  XET::App::Broadcasters.add port
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end

post "/api/broadcasters/add" do |env|
  port = env.params.url["port"].to_u16
  XET::App::Broadcasters.add port
  env.redirect(env.params.query["redirect"]? || "/")
rescue e
  Log.error { "#{e}" }
end