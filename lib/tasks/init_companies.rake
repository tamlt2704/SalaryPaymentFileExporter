namespace :companies do
  desc "Initialize default companies"
  task init: :environment do
    companies = [
      { name: "Company A" },
      { name: "Company B" },
      { name: "Company C" }
    ]

    companies.each do |attrs|
      Company.find_or_create_by!(name: attrs[:name])
    end
    puts "Initialized companies: #{companies.map { |c| c[:name] }.join(', ')}"
  end
end
