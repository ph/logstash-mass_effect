def bump_major_version(content)
  versions_parts = content.match(/s\.version\s+=\s'(\d+)\.(\d+)\.(\d+)'/).to_a
  if versions_parts[1].to_i <= 1
    new_version = 2
  else
    new_version = versions_parts[1].to_i + 1
  end
  content.gsub!(/s\.version\s+=\s'\d+\.\d+\.\d+'/, "s.version         = '#{new_version}.0.0'")
end


def logstash_core_2_0(content)
  # s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  content.gsub!(/add_runtime_dependency ("|')logstash-core("|').+/, 'add_runtime_dependency "logstash-core", "~> 2.0.0.snapshot"')
end

Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  content = File.read(gemspec)
  logstash_core_2_0(content)
  File.open(gemspec, "w+") { |f| f.write(content) }
end
