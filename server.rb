require 'socket'
require 'json'
require_relative 'employees_controller'

class RequestParser
  def parse(request)
    method, path, version = request.lines[0].split
    
    {
      path: path,
      method: method,
      headers: parse_headers(request),
      body: request.lines[-1].split
    }
  end

  def parse_headers(request)
    headers = {}
    
    request.lines[1..-1].each do |line|
      return headers if line == "\r\n"
      
      header, value = line.split
      header        = normalize(header)
      
      headers[header] = value
    end
  end
    
  def normalize(header)
    header.gsub(":", "").downcase.to_sym
  end
end

class Response
  attr_reader :code

  def initialize(code:, data: "")
    @response =
    "HTTP/1.1 #{code}\r\n" +
    "Content-Length: #{data.size}\r\n" +
    "\r\n" +
    "#{data}\r\n"
    
    @code = code
  end
  
  def send(client)
    client.write(@response)
  end
end

class ResponseBuilder
  SERVER_ROOT = "/home/wheatman/Documents/Rails/Softserve/homework/"
  
  def prepare(request)
    path = request.fetch(:path)
    method = find_method(request)
    params = decode_body(request)

    case [path, method]
    when ["/", "GET"]
      respond_with(SERVER_ROOT + "index.html")

    when ["/add/employee", "POST"]
      params = decode_body(request)
      EmployeesController.new(params)
      respond_with(SERVER_ROOT + "index.html")

    when [path.match(/\/employees\/\d+/).to_s, "GET"]
      response = File.binread(SERVER_ROOT + "show.html")
      employee_id = find_user_id(path)
      employee = EmployeesController.show(employee_id)
      response << employee.to_json
      send_ok_response(response)

  
    when [path.match(/\/employees\/\d+/).to_s, "PUT"]
      response = File.binread(SERVER_ROOT + "show.html")
      employee_id = find_user_id(path)
      params = decode_body(request)
      EmployeesController.update(employee_id, params)
      employee = EmployeesController.show(employee_id)
      response << employee.to_json
      send_ok_response(response)

    when [path.match(/\/employees\/\d+/).to_s, "DELETE"]
      employee_id = find_user_id(path)
      EmployeesController.delete(employee_id)
      respond_with(SERVER_ROOT + "index.html")
    
    when [path.match(/\/employees\?sort_by=\w+\?\w+/)[0], "GET"]
      sort_params = find_sort_params(path)
      employees = EmployeesController.index(sort_params).to_json
      send_ok_response(employees)

    else
      respond_with(SERVER_ROOT + request.fetch(:path))
    end
  end
  
  def respond_with(path)
    if File.exists?(path)
      send_ok_response(File.binread(path))
    else
      send_file_not_found
    end
  end

  def find_sort_params(path)
    sort_params = path.match(/=\w+\?\w+/)[0][1..-1].split("?")
  end
  
  def find_user_id(path)
    path.split("").select { |string| string[/\d+/]}.join("").to_i
  end

  def find_method(request)
    params = request.fetch(:body).join("")
    if params.include?("method")
      method = params.match(/method=\w+/)[0].split("=")[1].upcase
    else
      method = request.fetch(:method)
    end
  end

  def decode_body(request)
    params = request.fetch(:body).join("")
    if !params.empty? && params.include?("first_name")
      first_name = params.match(/=\w+&/)[0][1...-1]
      last_name = params.match(/&last_name=\w+/)[0][11..-1]
      salary = params.match(/&salary=\d+/)[0][8..-1]
      params = {first_name: first_name, last_name: last_name, salary: salary.to_i}
    end
  end

  def send_ok_response(data)
    Response.new(code: 200, data: data)
  end
  
  def send_file_not_found
    Response.new(code: 404)
  end
end

server  = TCPServer.new 3000

loop do
  client  = server.accept
  request = client.readpartial(2048)
  
  request  = RequestParser.new.parse(request)
  response = ResponseBuilder.new.prepare(request)
  
  puts "#{client.peeraddr[3]} #{request.fetch(:path)} - #{response.code}"
  
  response.send(client)
  client.close
end