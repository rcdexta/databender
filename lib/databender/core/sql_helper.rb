module Dbclip
  module SQLHelper

    def insert_into_select(source_db, table, condition = nil)
      sql = 'INSERT INTO %s SELECT * FROM %s.%s' % [table, source_db, table]
      sql += condition ? ' WHERE %s' % [condition] : " limit #{Dbclip::Config.max_rows}"
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

    def where_clause_by_reference(target_db, parents)
      parents.collect do |parent|
        '%s in (select %s from %s.%s)' % [parent.column_name, parent.ref_column_name, target_db, parent.ref_table_name]
      end.join(' and ')
    end

  end
end