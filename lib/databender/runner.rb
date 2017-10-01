require 'databender/version'
require 'yaml'
require 'mustache'
require 'terminal-table'
require 'databender/config'
require 'databender/sql_helper'
require 'databender/table'
require 'databender/connection'
require 'databender/table_order'

GEM_ROOT = File.expand_path("../..", __FILE__)

module Databender
  class Runner
    extend Databender::SQLHelper



    def self.generate_script(params)
      template = File.read("#{GEM_ROOT}/subset.sh.mustache")
      File.write('subset.sh', Mustache.render(template, params))
    end

    def self.apply_column_filters(table, source, source_db, target_db)
      columns = source.columns_for(source_db, table.name)
      overlapping_filters = Databender::Config.column_filters.keys & columns
      if overlapping_filters.present?
        column_filter = Databender::Config.column_filters[overlapping_filters.first]
        resolve_column_filter(target_db, overlapping_filters.first, column_filter)
      end
    end

    def self.process!(db_name)
      unless db_name
        puts 'Parameter db_name not specified. Terminating!'
        exit(1)
      end

      report = []

      Databender::Config.load!(db_name)
      target_db = Databender::Config.target_db
      source_db = Databender::Config.source.database

      source = Databender::Connection.new(Databender::Config.source.to_h)

      tables = source.tables_for(source_db)

      ## process tables with filters first
      tables.sort_by! {|table| [Databender::Config.table_filters.keys.include?(table.to_sym) ? 0 : 1, table]}

      all_tables = tables.collect {|table| Databender::Table.new(table)}

      ordered_tables = Databender::TableOrder.order_by_foreign_key_dependency(source, source_db, all_tables)

      entries = ordered_tables.collect do |table|
        column_filters = apply_column_filters table, source, source_db, target_db
        sql = count_all_query source_db, table.name
        all_count = source.execute_count(sql).first.first
        sql, count_query, filter = if Databender::Config.table_filters.keys.include?(table.name)
                             conditions = merge_filters(Databender::Config.table_filters[table.name], column_filters)
                             [insert_into_select(source_db, table.name, conditions),
                              count_filtered_query(source_db, table.name, conditions), conditions]
                           else
                             if column_filters.present?
                               [insert_into_select(source_db, table.name, column_filters), count_filtered_query(source_db, table.name, column_filters), column_filters]
                             else
                               parents = Databender::TableOrder.parent_tables_for(table.name)
                               condition = parents.present? ? where_clause_by_reference(target_db, parents) : nil
                               [insert_into_select(source_db, table.name, condition), count_filtered_query(source_db, table.name, condition), nil]
                             end
                                   end
        subset_count = source.execute_count(count_query).count
        report << [table.name, all_count, subset_count, filter && filter]
        {sql: sql, table: table.name}
      end

      headings = ['Table Name', 'Total Rows', 'Fetched Rows', 'Filter(s)']
      tty = Terminal::Table.new headings: headings, rows: report
      puts tty


      self.generate_script source: Databender::Config.source, target_db: target_db, entries: entries, database: db_name

    end
  end
end