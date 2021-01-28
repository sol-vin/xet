require "./app"

XET::App.setup

ph = XET::App::ProxyHandler.new
ph.start
sleep 1000
