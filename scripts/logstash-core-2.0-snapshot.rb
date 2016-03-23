def logstash_core_2_0(content)
  # s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  content.gsub!(/add_runtime_dependency ("|')logstash-core("|').+/, 'add_runtime_dependency "logstash-core", ">= 2.0.0.beta2", "< 3.0.0"')
end

Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  content = File.read(gemspec)
  logstash_core_2_0(content)
  File.open(gemspec, "w+") { |f| f.write(content) }
end
