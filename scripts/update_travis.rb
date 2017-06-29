require 'yaml'

Dir.glob("**/.travis.yml") do |travis|
  puts travis
  content = YAML.load(File.read(travis))

  new_matrix = {
    "matrix" => {
      "include" => [
        { "rvm" => "jruby-9.1.10.0", "env" => "LOGSTASH_BRANCH=master" },
        { "rvm" => "jruby-1.7.25", "env" => "LOGSTASH_BRANCH=5.x" },
      ],
      "fast_finish" => true
    }
  }

  content.merge!(new_matrix)
  IO.write(travis, YAML.dump(content))
end
