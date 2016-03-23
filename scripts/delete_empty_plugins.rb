# assume if they dont contains a CHANGELOG we can delete them

Dir.glob(File.join(File.expand_path('./tmp'), "*")).each do |directory|
  changelog = File.join(File.expand_path(directory), "CHANGELOG.md")

  if !File.exist?(changelog)
    cmd = "rm -rf #{File.expand_path(directory)}"
    puts cmd
    system(cmd)
  end
end

puts "Manual removal list.."
[
  "./tmp/logstash-filter-bytesize",
  "./tmp/logstash-filter-hashid",
  "./tmp/logstash-input-dynamodb",
  "./tmp/logstash-input-googleanalytics",
  "./tmp/logstash-input-journald",
  "./tmp/logstash-mixin-rabbitmq_connection",
  "./tmp/ruby-filereader",
  "./tmp/zenhub", 
  "./tmp/logstash-filter-yaml",
  "./tmp/logstash-input-log4j2",
  "./tmp/logstash-input-perfmon",
  "./tmp/logstash-output-firehose",
  "./tmp/logstash-output-logentries",
  "./tmp/logstash-output-newrelic",
  "./tmp/logstash-output-rados/",
  "./tmp/logstash-output-slack/",
  "./tmp/*-example"
].each do |directory|
  cmd = "rm -rf #{File.expand_path(directory)}"
  puts cmd
  system(cmd)
end
