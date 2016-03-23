  def update_file(file, &block)
    content = File.read(file)
    backup_content = content.dup

    block.call(content)
    save_content(file, content)
  rescue
    save_content(file, backup_content)
    puts "Something went wrong when updating the file, reverting it"
    raise
  end

  def save_content(file, content)
    File.open(file, "w+") { |f| f.write(content) }
  end
  
  Dir.glob(File.join(File.expand_path('./tmp'), '**/README.md')).each do |gemspec|
  update_file(gemspec) do |content|
    content.gsub!(/elasticsearch\.org/, "elastic.co")
    content.gsub!(/github\.com\/elasticsearch/, "github.com/elastic")
    content.gsub!(/elasticsearch\.com/, "elastic.co")
  end
end
