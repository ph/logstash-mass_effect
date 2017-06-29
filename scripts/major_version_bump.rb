def bump_version(file)
  content = File.read(file)
  versions_parts = content.match(/s\.version\s+=\s'(\d+)\.(\d+)\.(\d+)'/).to_a
  content.gsub!(/s\.version\s+=\s'\d+\.\d+\.\d+'/, "s.version         = '#{versions_parts[1].to_i + 1}.0.0'")
  
  File.open(file, 'w') do |f|
    f.write(content)
  end
end
Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  bump_version(gemspec)
end
