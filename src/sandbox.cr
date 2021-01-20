require "./xet"

socket = XET::Socket::TCP.new("10.0.0.5", 34567)
socket.login

socket.send_message XET::Command::Network::Common::Request.new
puts socket.receive_message.version