Dir.glob("tmp/**/docs/index.asciidoc") do |f|
  puts f
  content = File.read(f)
  content.gsub!('<<plugins-{type}s-common-options>>', '<<plugins-{type}s-{plugin}-common-options>>')
  content.gsub!(':include_path: ../../../logstash/docs/include', ':include_path: ../../../../logstash/docs/include')
  content = content.split("\n")
  last = content.pop

  if f !~ /codec/
    content << '[id="plugins-{type}s-{plugin}-common-options"]'
    content << last
  end

  IO.write(f, content.join("\n"))
end
