# assume if they dont contains a CHANGELOG we can delete them

Dir.glob(File.join(File.expand_path('./tmp'), "*")).each do |directory|
  changelog = File.join(File.expand_path(directory), "CHANGELOG.md")

  if !File.exist?(changelog)
    puts "rm -rf #{File.expand_path(directory)}"
  end
end
