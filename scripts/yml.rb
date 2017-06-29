# encoding: utf-8
puts "update YML"

require "yaml"

Dir.glob(File.join(File.expand_path('./tmp'), '**/.travis.yml')).each do |travis|
  cmd = 'travis encrypt "elastic:ibCjpvDoY4YeGYXQpSiZrGu6" --add notifications.slack --no-interactive'

  yml = YAML.load(File.read(travis))
  next if yml["notifications"] # we might need to do multiple run.. ty throttle

  Dir.chdir(File.dirname(travis)) do
    sleep(1)
    success = system(cmd)
    puts success
    exit if success == false
  end
end
