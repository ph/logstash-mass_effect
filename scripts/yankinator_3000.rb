require_relative "./helpers"


def yank_gems(gem, version)
  cmd = "gem yank #{gem} -v#{version}"
  puts system(cmd)
  sleep(0.2)
end

if !ARGV[0].nil? && ARGV[0].chomp == "-y"
  input = "y"
else
  puts "Welcome to yankinator 3000"
  puts "This program will now `gem yank` all the gems in `./tmp`, this operation cannot be undone."
  puts "Make sure you have the credentials to do that"
  puts "Do you want to proceed [y/n]"
  input = gets.chomp
end

if input == "y"
  puts "buckle your seat belt."

  path = File.join(File.expand_path(TARGET_PATH), "/**/*.gemspec")
  puts "Yanking all the gems in path: #{path}"


  Dir.glob(path).each do |gemspec|
    gem = File.dirname(gemspec).split(File::SEPARATOR).last
    version = Content.read_version(gemspec)
    puts "v: #{version}, gem: #{gem}, gemspec:#{gemspec}"
    yank_gems(gem, version)
  end
else
  puts "Operation cancelled, leaving gems untouched."
end
