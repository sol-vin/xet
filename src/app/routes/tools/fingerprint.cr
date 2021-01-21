get "/fingerprint" do |env|
  render_page "fingerprint/main"
end

get "/fingerprint/from_target/:name" do |env|
  name = env.params.url["name"]
  if target = XET::App::Targets[name]?

  else
    # TODO: Flash: TARGET DOES NOT EXIST!
    env.redirect("/fingerprint")
  end
end
