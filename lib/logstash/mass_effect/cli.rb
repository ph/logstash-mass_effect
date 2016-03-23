require 'thor'
require 'fileutils'

module LogStash
  module MassEffect
    class Cli < Thor
      option :organization, :default => 'logstash-plugins'
      option :target, :default => ENV['PWD']
      desc 'fork_all the plugins repository and clone them locally', 'masseffect fork_all --organization logstash-plugins --target ~/es'
      def fork_all
        Repository.new.fork_all(options[:organization], options[:target])
      end

      option :organization, :default => 'logstash-plugins'
      option :target, :default => ENV['PWD']
      option :only, :default => nil
      desc 'clone_all the plugins repository and clone them locally', 'masseffect clone_all --organization logstash-plugins --target ~/es'
      def clone_all
        Repository.new.clone_all(options[:organization], options)
      end

      option :target, :default => ENV['PWD']
      desc 'run_all shell command on target directory containing multiples repositories', 'masseffect run_all --c "git fetch upstream; git merge upstream/master --target ~/es'
      def run_all(command)
        Runner.new(options[:target]).parallel_command(command)
      end

      option :target, :default => ENV['PWD']
      desc 'apply', 'apply'
      def apply
        Repository.apply(options[:target])
      end

      option :organization, :default => 'logstash-plugins'
      desc 'rubygems_check', 'check if the gems was released on rubygems'
      def rubygems_check
        RubygemsValidator.verify!(options[:organization])
      end
      
      option :organization, :default => 'elasticsearch'
      option :repository, :default => 'logstash'
      option :before
      desc 'find the contributors for a specific file (Name + Github username)', 'masseffect contributors lib/event'
      def contributors(file, branch = 'master')
        Contributors.new(options.merge({ :branch => branch })).list(file)
      end
    end
  end
end
