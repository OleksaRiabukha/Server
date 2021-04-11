require_relative "db"

class EmployeesRepository

  def self.create(params)
    query = "INSERT INTO employees(first_name, last_name, salary) VALUES ('#{params[:first_name]}', '#{params[:last_name]}', '#{params[:salary]}')"
    Database.write(query)
  end

  def self.all(sort_params)
    query = "SELECT * FROM employees ORDER BY #{sort_params[0]} #{sort_params[1]}"
    employees = Database.fetch_all(query)
  end


  def self.find_employee(id)
    query = "SELECT * FROM employees WHERE ID=#{id}"
    result = Database.fetch_one(query)
  end


  def self.update_employee(id, params)
    query = "UPDATE employees SET first_name = '#{params[:first_name]}', last_name = '#{params[:last_name]}', salary = '#{params[:salary]}' WHERE ID = #{id}" 
    Database.update(query)
  end

  def self.delete_employee(id)
    query = "DELETE FROM employees WHERE ID = #{id}"
    Database.delete_employee(query)
  end
end