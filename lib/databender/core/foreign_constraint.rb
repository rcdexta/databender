module Dbclip
  class ForeignConstraint
    attr_accessor :table_name, :column_name, :ref_table_name, :ref_column_name

    def initialize(table_name, column_name, ref_table_name, ref_column_name)
      @table_name = table_name
      @column_name = column_name
      @ref_table_name = ref_table_name
      @ref_column_name = ref_column_name
    end
  end
end