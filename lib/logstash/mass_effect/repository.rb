require 'open3'
require 'forwardable'
require 'octokit'
require 'rugged'
require 'fileutils'
require 'cabin'
require 'gems'
require 'pry'

stack = Faraday::RackBuilder.new do |builder|
  builder.response :logger
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end

# Octokit.middleware = stack
module LogStash
  module MassEffect
    def self.logger(logger = Cabin::Channel.new)
      if @logger
        @logger
      else
        @logger ||= logger
        logger.subscribe(STDOUT)
        @logger
      end
    end

    def Downloader
      def self.fetch(file)
      end
    end

    class RubygemsValidator
      class ConfigurationError < StandardError; end

      GEM_CREDENTIALS_FILE = '~/.gem/credentials'

      # TODO version check too?
      def self.verify!(organization)
        @client = GithubApi.new

        @unreleased_gems = []
        @client.organization_repositories(organization).each do |repository|
          @unreleased_gems << repository[:name] unless verify(repository[:name])
        end

        if @unreleased_gems.size > 0
          puts "Cannot find theses gems on rubygems"
          @unreleased_gems.each { |gem_name| puts gem_name }
        else
          puts "All gems released to rubygems"
        end
      end

      def self.verify(name)
        # Assume you have correctly configured the ~/gem/credentials file
        credentials_file = File.expand_path(GEM_CREDENTIALS_FILE)

        if File.exist?(credentials_file)
          response = Gems.versions(name)
          if response != 'This rubygem could not be found.'
            return response.first.fetch('number', nil)
          else
            return nil
          end
        else
          raise ConfigurationError.new("Missing rubygems credentials in #{credentials_file}")
        end
      end
    end

    class GithubApi
      extend Forwardable
      def_delegators :@client, :organization_repositories, :fork

      def initialize
        enable_debugging if debug?

        Octokit.auto_paginate = true
        @client = Octokit::Client.new(:netrc => true)
      end

      def debug?
        ENV["DEBUG"]
      end

      def enable_debugging!
        stack = Faraday::RackBuilder.new do |builder|
          builder.response :logger
          builder.use Octokit::Response::RaiseError
          builder.adapter Faraday.default_adapter
        end

        Octokit.middleware = stack
      end
    end

    class Context
      attr_reader :repository
      attr_reader :code

      def initialize(code, repostitory = nil)
        @repository = repository
        @code = code.read
      end

      def create_branch(name)
      end

      def run
        instance_eval do
          eval(code) 
        end
      end

      def self.from_string(string)
        new(String.new(string))
      end

      def self.from_file(file)
        new(File.new(file))
      end
    end

    class Runner
      attr_reader :target

      def initialize(target)
        @target = target
      end

      def parallel_command(cmd)
        Repository.local_repositories(target).each do |repository|
          command(cmd, File.join(repository))
        end
      end

      def command(cmd, target)
        MassEffect.logger.info('running command', :cmd => cmd, :target => target)
        Dir.chdir(target) do
          puts system(cmd)
        end
      end
    end

    class Repository
      REMOTE_DEFAULT = 'upstream'

      def initialize(options = {})
        @dry_run = options[:dry_run]
      end

      def dry_run?
        @dry_run
      end

      def client
        @client ||= GithubApi.new
      end

      def fork_all(organization, target)
        repositories = client.organization_repositories(organization)
        repositories.each do |repository|
          fork = client.fork("#{organization}/#{repository[:name]}")
          repository = clone(fork[:parent][:clone_url], File.join(target, repository[:name]))
          setup_remotes(repository, fork)
        end
      end

      def clone_all(organization, options = {})
        puts "clone all"
        target = options[:target]
        repositories = client.organization_repositories(organization)
        puts "size before: #{repositories.size}"
        repositories = filtered(repositories, options[:only]) if options[:only]
        puts "size after: #{repositories.size}"

        repositories.each do |repository|
          repository = clone(repository[:git_url], File.join(target, repository[:name]))
        end
      end

      def filtered(repositories, source)
        load File.expand_path(source)
        repositories.delete_if { |repository|  !LogStash::RakeLib::DEFAULT_PLUGINS.include?(repository[:name]) }
      end

      def apply_inline(inline_code)
        context = Context.from_string(inline_code)
        context.run
      end

      def apply(file)
        context = Context.from_file(file)
        context.run
      end

      def clone(repository_url, target)
        if Repository.repository?(target)
          Rugged::Repository.new(target)
        else
          MassEffect.logger.info('Cloning', :repository => repository_url)
          FileUtils.mkdir_p(target)
          Rugged::Repository.clone_at(repository_url, target)
        end
      end

      def setup_remotes(repository, fork)
        MassEffect.logger.info('Configure Remote',
                               :origin => fork[:git_url],
                               :upstream => fork[:parent][:clone_url])

        repository.remotes.delete('origin')
        repository.remotes.create('origin', fork[:git_url])
        repository.remotes.create('upstream', fork[:parent][:clone_url])
      end

      def self.local_repositories(target)
        Dir.glob(File.join(target, '*')).select { |f| Repository.repository?(f) }
      end

      def self.repository?(target)
        begin
          return false unless Dir.exist?(target)
          return Rugged::Repository.new(target)
        rescue Rugged::RepositoryError
          return false
        end
      end
    end

    class Contributors
      attr_reader :repository
      attr_reader :branch
      attr_reader :organization
      attr_reader :before

      def initialize(options = {}) 
        @organization = options[:organization]
        @repository = options[:repository]
        @branch = options[:branch]
        @before = Time.parse(options[:before]) unless options[:before].nil?
      end

      def client
        Octokit.auto_paginate = true
        @client = Octokit::Client.new(:netrc => true)
      end

      def list(file)
        options = { :sha => branch, :path => file}
        options[:until] = before unless before.nil?

        commits = client.commits("#{organization}/#{repository}/", options)

        contributors = []
        commits
          .delete_if { |c| c.author.nil? } # Some commit can be bogus? Not sure why...
          .uniq { |c| c.author.login }
          .each do |commit|

          login = commit.author.login
          name = client.user(login).name

          contributors << if name.nil? or name == ""
            login
          else
            "#{name} (#{login})"
          end
        end

        if contributors.size > 0
          begin
            STDOUT.sync = true
            contributors.each { |c| $stdout.puts c }
            exit 0
          rescue Errno::EPIPE
            exist(74)
          end
        else
          puts 'no contributors found'
          exit 99
        end
      end
    end
  end
end
