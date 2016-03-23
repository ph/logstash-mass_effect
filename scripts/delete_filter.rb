require_relative "helpers"

edit_matched_files("/*/lib/**/*.rb", "/*/spec/**/*.rb") do |content|
  content.matched_replace!(/return unless filter\?.+/, '')
  content.save
end
