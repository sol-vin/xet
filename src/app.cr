require "./xet"

xmsg = XET::Command::Bits::Request.new
puts xmsg.to_json

xmsg = XET::Command::Network::Common::Reply.new
puts xmsg.to_json
