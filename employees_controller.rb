require_relative "employees_service"

class EmployeesController

  def self.new(params)
    EmployeesService.create(params)
  end

  def self.show(id)
    EmployeesService.show(id)
  end

  def self.update(id, params)
    EmployeesService.update(id, params)
  end

  def self.index(sort_params)
    employees = EmployeesService.all(sort_params)
  end

  def self.delete(id)
    EmployeesService.destroy(id)
  end

  def self.fetch_data_from_db
    result = Database.read_all
  end

end
