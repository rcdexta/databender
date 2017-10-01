require 'databender/version'
require 'yaml'
require 'mustache'
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
      tables.sort_by! { |table| [Databender::Config.table_filters.keys.include?(table.to_sym) ? 0 : 1, table] }

      all_tables = tables.collect { |table| Databender::Table.new(table) }

      ordered_tables = Databender::TableOrder.order_by_foreign_key_dependency(source, source_db, all_tables)

      entries = ordered_tables.collect do |table|
        sql = if Databender::Config.table_filters.keys.include?(table.name)
                insert_into_select source_db, table.name, Databender::Config.table_filters[table.name]
              else
                columns = source.columns_for(source_db, table.name)
                overlapping_filters = Databender::Config.column_filters.keys & columns
                if overlapping_filters.present?
                  column_filter = Databender::Config.column_filters[overlapping_filters.first]
                  condition = resolve_column_filter(target_db, overlapping_filters.first, column_filter)
                  insert_into_select source_db, table.name, condition
                else
                  parents = Databender::TableOrder.parent_tables_for(table.name)
                  condition = parents.present? ? where_clause_by_reference(target_db, parents) : nil
                  insert_into_select source_db, table.name, condition
                end
              end
        {sql: sql, table: table.name}
      end

      self.generate_script source: Databender::Config.source, target_db: target_db, entries: entries, database: db_name

    end
  end
end