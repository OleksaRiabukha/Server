require 'pg'

class Database

  def self.fetch_all(query)
    connection = connect_to_db
    result = connection.exec(query)
    connection.close
    result
  end

  def self.fetch_one(query)
    connection = connect_to_db
    result = connection.exec(query)
    connection.close
    result
  end

  def self.write(query)
    connection = connect_to_db
    connection.exec(query)
    connection.close
  end

  def self.update(query)
    connection = connect_to_db
    connection.exec(query)
    connection.close
  end

  def self.delete_employee(query)
    connection = connect_to_db
    connection.exec(query)  
    connection.close
  end

  private 

  def self.connect_to_db
    PG.connect :dbname => 'emoployees', :user => 'softserve', :password => 'softserve'
  end
end