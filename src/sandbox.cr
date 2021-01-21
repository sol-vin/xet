require "./app_lib"

socket = XET::App::Broadcaster.new
socket.start_listening
socket.start_broadcasting

sleep 1
puts socket.listen?
puts socket.listen?
sleep 1
socket.close
sleep 1