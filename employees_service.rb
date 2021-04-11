require_relative "employees_repo"

class EmployeesService
  def self.create(params)
    EmployeesRepository.create(params)
  end


  def self.all(sort_params)
    employees = []
    db_employees = EmployeesRepository.all(sort_params)
    db_employees.each do |employee|
      employees << employee
    end        
    employees
  end

  def self.show(id)
    employeee_db_odject = EmployeesRepository.find_employee(id) 
    employee = []
    employeee_db_odject.each do |employee_details|
      employee << employee_details
    end
    employee
  end

  def self.update(id, params)
    EmployeesRepository.update_employee(id, params)
  end

  def self.destroy(id)
    EmployeesRepository.delete_employee(id)
  end
end