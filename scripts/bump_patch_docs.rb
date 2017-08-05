require_relative "helpers"

GEMSPEC_VERSION_RE = /s\.version\s+=\s'(\d+)\.(\d+)\.(\d+)'/

def bump_version(file)
  content = File.read(file)

  match = content.match(GEMSPEC_VERSION_RE)

  if match
    major, minor, patch = match.captures.map(&:to_i)
    patch += 1
    version = "#{major}.#{minor}.#{patch}"
    content[match.begin(1) ... match.end(3)] = version
    File.write(file, content)
    return version
  else
    # gemspec probably uses some other way to set the version.
    # Look for a file named 'VERSION' or 'version' containing just the version number.
    [ "VERSION", "version" ].each do |name|
      path = File.join(File.dirname(file), name)
      if File.exist?(path)
        major, minor, patch = File.read(path).chomp.split(".").map(&:to_i)
        patch = patch + 1
        version = "#{major}.#{minor}.#{patch}"
        File.write(path, version)
        return version
      end
    end
  end
end

Dir.glob(File.join(File.expand_path('./tmp'), '**/*.gemspec')).each do |gemspec|
  version = bump_version(gemspec)

  begin
    content = File.read(gemspec)

    # Add load path for the plugin
    $LOAD_PATH << File.join(File.dirname(gemspec), "lib")

    # chdir so file paths are relative to the plugin dir.
    spec = Dir.chdir(File.dirname(gemspec)) do
      # Execute the gemspec. We should get a Gem::Specification from this.
      eval(content)
    end
  rescue => e
    puts "FAILED: #{gemspec}"
    puts " - - #{e}"
    next
  end

  version = spec.version.to_s

  changelog_content = <<-CHANGELOG
## #{version}
  - Fix some documentation issues
  CHANGELOG

  changelog_path = File.join(File.dirname(gemspec), "CHANGELOG.md")
  old_changelog = File.read(changelog_path);
  File.write(changelog_path, changelog_content + "\n" + old_changelog);
end

