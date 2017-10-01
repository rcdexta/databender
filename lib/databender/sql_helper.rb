require 'databender/config'

module Databender
  module SQLHelper

    def insert_into_select(source_db, table, condition = nil)
      sql = 'INSERT INTO %s SELECT * FROM %s.%s' % [table, source_db, table]
      sql = apply_condition(condition, sql)
      sql
    end

    def resolve_column_filter(target_db, column, filter)
      if filter.starts_with? 'refers'
        match = filter.match(/refers\((\w+),\s*(\w+)/)
        '%s in (select %s from %s.%s)' % [column, match[2], target_db, match[1]]
      else
        filter
      end
    end

    def merge_filters(filter, additional_filter)
      additional_filter ? [filter, 'and', additional_filter].join(' ') : filter
    end

    def where_clause_by_reference(target_db, parents)
      parents.collect do |parent|
        '%s in (select %s from %s.%s)' % [parent.column_name, parent.ref_column_name, target_db, parent.ref_table_name]
      end.join(' and ')
    end

    def count_all_query(source_db, table)
      'SELECT count(1) cnt from %s.%s' % [source_db, table]
    end

    def count_filtered_query(source_db, table, condition = nil)
      sql = 'SELECT 1 from %s.%s' % [source_db, table]
      sql = apply_condition(condition, sql)
      sql
    end

    private

    def apply_condition(condition, sql)
      sql += condition ? ' WHERE %s' % [condition] : " limit #{Databender::Config.max_rows}"
      sql
    end


  end
end