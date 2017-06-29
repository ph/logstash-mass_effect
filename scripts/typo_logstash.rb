# encoding: utf-8
require 'fileutils'
puts "UPDATING LICENSE"

def update_file(file, &block)
  content = File.read(file)
  backup_content = content.dup

  block.call(content)
  save_content(file, content)
rescue
  save_content(file, backup_content)
  puts "Something went wrong when updating the file, reverting it"
  raise
end

def save_content(file, content)
  File.open(file, "w+") { |f| f.write(content) }
end

Dir.glob(File.join(File.expand_path('./tmp'), '**/README.md')).each do |readme|
  update_file(readme) do |content|
    content.gsub!("bin/logstah-plugin", "bin/logstash-plugin")
  end
end
