require_relative "helpers"

def logstash_core(content)
  # s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  content.gsub!(/add_runtime_dependency ("|')logstash-core("|').+/, 'add_runtime_dependency "logstash-core-plugin-api", "~> 1.0"')
end

def bump_version(file)
  content = File.read(file)
  versions_parts = content.match(/s\.version\s+=\s['"](\d+)\.(\d+)\.(\d+)['"]/).to_a
  content.gsub!(/s\.version\s+=\s['"]\d+\.\d+\.\d+['"]/, "s.version         = '#{versions_parts[1]}.#{versions_parts[2]}.#{versions_parts[3].to_i + 1}'")
  
  File.open(file, 'w') do |f|
    f.write(content)
  end
end

Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  bump_version(gemspec)
  content = File.read(gemspec)
  logstash_core(content)
  File.open(gemspec, "w+") { |f| f.write(content) }
end
