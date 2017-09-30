module Databender
  module Cli
    class Main < Thor
      include Thor::Actions

      source_root File.expand_path('../../templates', __FILE__)

      option :database, required: true, desc: 'Name of the database'
      option :driver, required: false, desc: 'Driver: mysql|postgres', default: 'mysql'
      desc 'init', 'Initialize configuration and filters'
      def init
        say 'Creating baseline configuration and filter...', :green
        template 'database.yml', 'config/database.yml'
        filter_path = "config/filters/#{options[:database]}.yml"
        template 'filter.yml', filter_path
        empty_directory 'dumps'
        empty_directory 'reports'
        say "Please review #{filter_path} to verify initial settings.", :green
      end

      option :database, required: true, desc: 'Name of the database'
      desc 'dry_run', 'Run a dry-run of the subset script'
      def dry_run
        say "Analyzing #{options[:database]}", :green
      end

    end
  end
end

