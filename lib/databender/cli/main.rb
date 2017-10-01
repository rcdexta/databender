require_relative '../../../lib/databender/runner'

module Databender
  module Cli
    class Main < Thor
      include Thor::Actions


      source_root File.expand_path('../../templates', __FILE__)

      option :db_name, required: true, desc: 'Name of the database'
      option :driver, required: false, desc: 'Driver: mysql|postgres', default: 'mysql'
      desc 'init', 'Initialize configuration and filters'
      def init
        say 'Creating baseline configuration and filter...', :green
        template 'database.yml', 'config/database.yml'
        filter_path = "config/filters/#{options[:db_name]}.yml"
        template 'filter.yml', filter_path
        say "Please review #{filter_path} to verify initial settings.", :green
      end

      option :db_name, required: true, desc: 'Name of the database'
      desc 'dry_run', 'Perform a dry-run of the subset script without importing the data'
      def dry_run
        say "Analyzing #{options[:db_name]}", :green
      end

      option :db_name, required: true, desc: 'Name of the database'
      desc 'generate', 'Generate subset given a database'
      def generate
        say "Creating subset for #{options[:db_name]}", :green
        source, report_queries = Databender::Runner.process! options[:db_name]
        run 'sh subset.sh', verbose: false
        Databender::Runner.print_report source, report_queries
      end

    end
  end
end

