# Renders an ecr file with the layout around it
macro render_page(filename)
  render "./src/app/views/pages/#{{{filename}}}.ecr", "./src/app/views/layout.ecr"
end

# Renders just an ecr file
macro render_file(filename)
  render "./src/app/views/reuse/#{{{filename}}}.ecr"
end