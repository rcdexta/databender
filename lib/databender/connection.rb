require 'active_record'
require 'databender/foreign_constraint'

module Databender
  class Connection

    def initialize(connection_params)
      @conn = ActiveRecord::Base.establish_connection(connection_params).connection
    end

    def execute(sql)
      @conn.execute(sql).entries.flatten.compact.map(&:to_sym)
    end

    def execute_count(sql)
      @conn.execute(sql)
    end

    def tables_for(db_name)
      execute(%[
                  SELECT table_name
                  FROM information_schema.tables
                  WHERE table_schema = '#{db_name}' and table_type = 'BASE TABLE';
              ])
    end

    def columns_for(db_name, table_name)
      execute(%[
                  SELECT column_name
                  FROM information_schema.columns
                  WHERE table_schema = '#{db_name}'
                        and table_name = '#{table_name}';
               ])
    end

    def foreign_key_dependency_map_for(db_name)
      rows = @conn.execute(%[
                              SELECT table_name, column_name, referenced_table_name, referenced_column_name
                              FROM information_schema.key_column_usage
                              WHERE table_schema = '#{db_name}' AND referenced_table_name is not null
                              AND table_name != referenced_table_name
                              ORDER BY table_name;
                            ])
      rows.each_with_object({}) do |row, map|
        table, column, ref_table_name, ref_column_name = row
        parent = ForeignConstraint.new(table, column, ref_table_name, ref_column_name)
        map.has_key?(table) ? map[table] << parent : map[table] = [parent]
      end.symbolize_keys
    end

  end
end