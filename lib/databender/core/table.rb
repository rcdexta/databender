module Dbclip
  class Table
    attr_accessor :name, :rank, :parents

    def initialize(name)
      @name = name
      @rank = nil
      @parents = []
    end

    def inspect
      "#{@name} -> #{@rank}"
    end
  end
end