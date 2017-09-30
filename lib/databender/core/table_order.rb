module Dbclip
  class TableOrder

    class << self

      def order_by_foreign_key_dependency(source, db_name, tables_with_rank)
        @tables_with_rank = unique_group_by(tables_with_rank, :name).with_indifferent_access
        @dependency_map = source.foreign_key_dependency_map_for(db_name).with_indifferent_access
        tables_with_no_dependencies = @tables_with_rank.keys - @dependency_map.keys
        tables_with_no_dependencies.each { |table_name| @tables_with_rank[table_name].rank = 0 }
        @dependency_map.keys.each do |table|
          rank_for(table)
          # p @tables_with_rank[table]
        end
        @tables_with_rank.values.flatten.sort {|x,y| x.rank <=> y.rank}
      end

      def rank_for(table)
        @tables_with_rank[table].rank ||= @dependency_map[table].collect do |parent|
                                              @tables_with_rank[parent.ref_table_name].rank ||= rank_for(parent.ref_table_name)
                                          end.max + 1
      end

      def unique_group_by(array, key)
        array.each_with_object({}) do |element, hash|
          hash[element.send(key)] = element
        end
      end

      def parent_tables_for(table_name)
        @dependency_map[table_name]
      end

    end

  end
end