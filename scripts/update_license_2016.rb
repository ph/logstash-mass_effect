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

Dir.glob(File.join(File.expand_path('./tmp'), '**/LICENSE')).each do |gemspec|
  update_file(gemspec) do |content|
    content.gsub!('2012–2015', '2012–2016')
  end
end

puts "COPYING GITHUB TEMPLATES"
Dir.glob(File.join(File.expand_path('./tmp'), '*')).each do |directory|
  target = File.join(directory, '.github')
  FileUtils.cp_r("./templates/github_templates/", target)
end

puts "Update README.md"
new_plugin = <<-EOS
# Logstash 2.3 and higher
bin/logstash-plugin install /your/local/plugin/logstash-filter-awesome.gem

# Prior to Logstash 2.3
bin/plugin install /your/local/plugin/logstash-filter-awesome.gem 
EOS

new_plugin2 = <<-EOS
# Logstash 2.3 and higher
bin/logstah-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify
EOS

Dir.glob(File.join(File.expand_path('./tmp'), '**/README.md')).each do |readme|
  update_file(readme) do |content|
    content.gsub!("bin/plugin install --no-verify", new_plugin2)
    content.gsub!("bin/plugin install /your/local/plugin/logstash-filter-awesome.gem", new_plugin2)
  end
end

puts "Update Gemspec's description"
new_description = 's.description     = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"'

Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  update_file(gemspec) do |content|
    content.gsub!(/s.description.+/, new_description)
  end
end


