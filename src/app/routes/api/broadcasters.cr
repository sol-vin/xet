get "/api/broadcasters/:port/start_listening" do |env|
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

get "/api/broadcasters/:port/stop_listening" do |env|
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

get "/api/broadcasters/:port/start_broadcasting" do |env|
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

get "/api/broadcasters/:port/stop_broadcasting" do |env|
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

get "/api/broadcasters/:port/delete" do |env|
  port = env.params.url["port"].to_u16
  XET::App::Broadcasters.delete port
rescue e
  Log.error { "#{e}" }
end