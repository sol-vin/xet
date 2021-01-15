require "./xet"

socket = XET::Socket::UDP.new("255.255.255.255", 34569)
socket.bind ::Socket::IPAddress.new("0.0.0.0", 34569)
socket.broadcast = true
socket.close
begin
  socket.send_message XET::Command::Login::Request.new
rescue e
  puts e
end