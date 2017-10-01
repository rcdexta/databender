require 'configatron'

module Databender
  class Config
    class << self

      def load!(db_name, config_path = 'config/database.yml')
        db_yml = config_path
        db_config = YAML::load(IO.read(db_yml))
        filter_config = YAML::load(IO.read("config/filters/#{db_name}.yml"))
        configatron.configure_from_hash(filter_config.merge({source: db_config[db_name]}))
      end

      def target_db
        "#{configatron.source.database}_subset"
      end

      def table_filters
        configatron.tables.filters || {}
      end

      def max_rows
        configatron.tables.max_row_count
      end

      def column_filters
        configatron.columns.filters || {}
      end

      def method_missing(method)
        if method == :configatron
          super(method)
        else
          configatron[method]
        end
      end

    end
  end
end