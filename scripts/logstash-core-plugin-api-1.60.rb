require_relative "helpers"

def relax_plugin_api_dependency(content)
  # turn:
  #   s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  # into:
  #   s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  content.gsub!(/add_runtime_dependency ["']logstash-core-plugin-api["'].+2\.0.+/, 'add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"')
end

def bump_version(gemspec_content)
  versions_parts = gemspec_content.match(/s\.version\s+=\s['"](\d+)\.(\d+)\.(\d+)['"]/).to_a
  gemspec_content.gsub!(/s\.version\s+=\s['"]\d+\.\d+\.\d+['"]/, "s.version         = '#{versions_parts[1]}.#{versions_parts[2]}.#{versions_parts[3].to_i + 1}'")
end


Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  content = File.read(gemspec)

  changed_content = content.dup
  bump_version(changed_content)
  if content == changed_content
    puts "failed to process stage 1 of #{gemspec}, skipping"
    next
  else
    content = changed_content
  end

  changed_content = content.dup
  relax_plugin_api_dependency(changed_content)
  if content == changed_content
    puts "failed to process stage 2 of #{gemspec}, skipping"
    next
  else
    content = changed_content
  end

  File.open(gemspec, "w+") { |f| f.write(content) }

  changelog_content = "  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99\n\n"
  changelog_path = File.join(gemspec.split("\/")[0...-1] << "CHANGELOG.md")
  update_changelog(changelog_content, changelog_path)
end

