Dir.glob("plugins9k/**/index.asciidoc") do |index|
  puts index
  _, plugin_name, _= index.split("/")

  _, type, name = plugin_name.split("-")

  content = File.read(index)
  content.gsub!(/===\s#{name}$/i, "=== #{name.capitalize} #{type} plugin")
  IO.write(index, content)
end
