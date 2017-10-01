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

    def self.print_report(source, report_queries)
      report = []
      report_queries.each do |rq|
        all_count = source.execute_count(rq[:all_count_sql]).first.first
        subset_count = source.execute_count(rq[:filter_count_sql]).count
        report << [rq[:table], all_count, subset_count, rq[:filter]]
      end
      headings = ['Table Name', 'Total Rows', 'Fetched Rows', 'Filter(s)']
      tty = Terminal::Table.new headings: headings, rows: report
      puts ''
      puts 'Generating report...'
      puts tty
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

      Databender::Config.load!(db_name)
      target_db = Databender::Config.target_db
      source_db = Databender::Config.source.database

      source = Databender::Connection.new(Databender::Config.source.to_h)

      tables = source.tables_for(source_db)

      ## process tables with filters first
      tables.sort_by! {|table| [Databender::Config.table_filters.keys.include?(table.to_sym) ? 0 : 1, table]}

      all_tables = tables.collect {|table| Databender::Table.new(table)}

      ordered_tables = Databender::TableOrder.order_by_foreign_key_dependency(source, source_db, all_tables)

      report_queries = []

      entries = ordered_tables.collect do |table|
        column_filters = apply_column_filters table, source, source_db, target_db
        all_count_sql = count_all_query source_db, table.name
        sql, filter_count_sql, filter = if Databender::Config.table_filters.keys.include?(table.name)
                             conditions = merge_filters(Databender::Config.table_filters[table.name], column_filters)
                             [insert_into_select(source_db, table.name, conditions),
                              count_filtered_query(source_db, table.name, conditions), conditions]
                           else
                             if column_filters.present?
                               [insert_into_select(source_db, table.name, column_filters), count_filtered_query(source_db, table.name, column_filters), column_filters]
                             else
                               parents = Databender::TableOrder.parent_tables_for(table.name)
                               condition = parents.present? ? where_clause_by_reference(target_db, parents) : nil
                               [insert_into_select(source_db, table.name, condition), count_filtered_query(source_db, table.name, condition), condition]
                             end
                                   end
        report_queries << {table: table.name, all_count_sql: all_count_sql, filter_count_sql: filter_count_sql, filter: filter}
        {sql: sql, table: table.name}
      end

      self.generate_script source: Databender::Config.source, target_db: target_db, entries: entries, database: db_name
      [source, report_queries]
    end
  end
end