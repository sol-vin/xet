require "./app_lib"

xmsg = XET::Command::Network::Common::Reply.new(
  config: XET::Command::Network::Common::Reply::Config.new(
    build_date: "whenever"
  )
)

puts xmsg.to_json
