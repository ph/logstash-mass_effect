require_relative "helpers"

content =<<DOC
  - Now depend on `logstash-core-plugin-api` instead of `logstash-core`, this remove the need to mass update 
    the plugins if the plugin api contract doesn't change.
DOC

update_changelog(content)
