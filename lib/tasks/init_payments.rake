namespace :payments do
  desc "Initialize sample payments for each company and employee"
  task init: :environment do
    companies = Company.all
    employees = Employee.all
    if companies.empty? || employees.empty?
      puts "No companies or employees found. Please initialize them first."
      next
    end

    companies.each do |company|
      employees.where(company_id: company.id).each do |employee|
        Payment.find_or_create_by!(
          company: company,
          employee_id: employee.employee_id,
          bank_bsb: "123456",
          bank_account: "1234567",
          amount_cents: 1000,
          currency: "AUD",
          pay_date: Date.today,
          status: :pending
        )
      end
    end
    puts "Initialized payments for all companies and employees."
  end
end
