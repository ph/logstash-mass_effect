require 'pathname'

TARGET_PATH = "./tmp"

def update_changelog(text, match = "*/CHANGELOG.md")
  edit_matched_files(match) do |content|
    content.shift(text)
    version = content.read_version
    content.shift("## #{version}\n")
    content.save
  end
end


# add a higher level abstraction called `plugins`
# handy for doing condition on the version of the specific plugin
def edit_matched_files(*match, &block)
  match.each do |m|
    if Pathname.new(m).absolute?
      path = m
    else
      path = File.join(File.expand_path(TARGET_PATH), m)
    end
    puts "path: #{path}"

    Dir.glob(path).each do |file|
      block.call(Content.create(file))
    end
  end
end

def edit_gemspec(&block)
  edit_matched_files("**/*.gemspec", block)
end

class Content
  def initialize(content, file)
    @content = content
    @backup = content.dup
    @file = file
  end

  def read_version
    begin
      file = Dir.glob(File.join(File.dirname(@file), "*.gemspec")).first
      extract_version(file)
    rescue => e
      require "pry"
      binding.pry
      puts "errors on #{@file}"
      raise e
    end
  end

  def extract_version(gemspec)
    content = File.read(gemspec)
    content.match(/s\.version\s+=\s['"](\d+\.\d+\.\d+)['"]/).to_a[1]
  end

  def matched_replace!(find, replace)
    if @content =~ find
      puts "replacing: #{find} in #{@file}"
      @content.gsub!(find, replace)
    end
  end

  def shift(content)
    @content = content + @content
  end

  def save
    begin
      if @content != @backup
        persist_content
        changed!
        puts "Successfully updated: #{@file}"
      end
    rescue => e
      restore_backup
      raise e
    end
  end

  def changed!
    @changed = true
  end

  def changed?
    @changed
  end

  def persist_content
    save_to_file(@content)
  end

  def restore_backup
    save_to_file(@backup_content)
  end

  def save_to_file(content)
    File.open(@file, "w+") { |f| f.write(content) }
  end

  def commit(message)
    if changed? 
      puts system('git add #{@file}; git commit -am "#{message}"')
    end
  end

  def self.create(file)
    content = File.read(file)
    new(content, file)
  end
end
