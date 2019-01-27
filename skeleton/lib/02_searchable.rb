require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    where_line = []
    values = []
    params.each do |k,v| 
      where_line << "#{k} = ?"
    values << v
    end
    where_line = where_line.join(" AND ")
    res = DBConnection.execute(<<-SQL, *values)
      SELECT *
      FROM #{table_name}
      WHERE #{where_line}
    SQL
    parse_all(res)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
