require_relative "helpers"

content =<<DOC
  - Republish all the gems under jruby.
DOC

update_changelog(content)
