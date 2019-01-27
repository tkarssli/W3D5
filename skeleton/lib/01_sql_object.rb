require_relative 'db_connection'
require 'active_support/inflector'
require "byebug"
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    unless @columns
      t = self.table_name
      res = DBConnection.execute2(<<-SQL)
        SELECT *
        FROM #{t}
      SQL
      @columns = res[0].map{|s| s.to_sym}
    end
    @columns
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do 
        attributes[col]
      end

      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name= table_name
  end

  def self.table_name
    # ...
    unless @table_name
      @table_name = self.to_s.tableize
    end
    @table_name
  end

  def self.all
    # ...
    res = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    self.parse_all(res)
  end

  def self.parse_all(results)
    # ...
    res = []
    results.map do |hash|
    res <<  self.new(hash)
    end
    res
  end

  def self.find(id)
    # ...
    res = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
      WHERE id = #{id}
      LIMIT 1
    SQL
    
    return res.empty? ? nil : self.new(res[0])
  end

  def initialize(params = {})
    # ...
    params.each do |key,val|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
      self.send("#{key.to_s}=",val)
    end
  end

  def attributes
    # ...
    @attributes || @attributes = {}
  end

  def attribute_values
    # ...

    self.class.columns.map do |col|
      self.send(col)
    end
  end

  def insert
    # ...
    col_names = self.class.columns[1..-1].join(",")
    question_marks =(["?"] * (self.class.columns[1..-1].length)).join(",")
    attributes = self.attribute_values[1..-1]
    res = DBConnection.execute(<<-SQL, *attributes)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    col_names = self.class.columns[1..-1]
    set = col_names.map{ |col| "#{col.to_s} = ?"}.join(",")
    attributes = self.attribute_values
    res = DBConnection.execute(<<-SQL, *attributes[1..-1], attributes[0])
      UPDATE #{self.class.table_name}
      SET #{set}
      WHERE id = ?
    SQL
  end

  def save
    # ...
    self.id ? self.update : self.insert

  end
end
