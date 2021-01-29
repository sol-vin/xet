require "./app"

XET::App.setup

ph = XET::App::ProxyHandler.new
ph.cameras_filter.ip_addresses << "10.0.0.5"
ph.clients_filter.target_all = true

ph.start
sleep 1000
