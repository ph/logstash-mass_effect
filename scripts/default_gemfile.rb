 require_relative 'helpers'
 require "fileutils"

 gemfile = File.expand_path("./templates/Gemfile")
Dir.glob(File.join(File.expand_path('./tmp'), "*")).each do |directory|
  target = File.join(directory, "Gemfile")
  FileUtils.rm_rf(target)
  FileUtils.cp(gemfile, target)
end

