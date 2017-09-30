module Dbclip
  class Config
    class << self

      def load!(db_name)
        db_yml = ENV['DB_CONFIG'] || 'config/database.yml'
        db_config =  YAML::load(IO.read(db_yml))
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
          configatron[method]
      end

    end
  end
end