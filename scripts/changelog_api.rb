require_relative "helpers"

content =<<DOC
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
DOC

update_changelog(content)
