class EmployeesController < ApplicationController
  def index
    employees = Employee.select(:id, :employee_id, :name, :company_id)
    render json: employees
  end

  def show
    employee = Employee.find(params[:id])
    render json: employee
  end

  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def employee_params
    params.require(:employee).permit(:employee_id, :name, :company_id)
  end
end
