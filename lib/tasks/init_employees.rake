namespace :employees do
  desc "Initialize sample employees for each company"
  task init: :environment do
    companies = Company.all
    if companies.empty?
      puts "No companies found. Please initialize companies first."
      next
    end

    companies.each do |company|
      3.times do |i|
        Employee.find_or_create_by!(
          company: company,
          employee_id: "emp#{company.id.to_s.rjust(2, '0')}_#{i+1}",
          name: "Employee #{i+1} of #{company.name}"
        )
      end
    end
    puts "Initialized 3 employees for each company."
  end
end
