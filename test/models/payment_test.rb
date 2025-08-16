require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "the truth" do
    first_company = Company.find_by(name: "abc_101")
    payments_company_one = Payment.where(company_id: first_company.id)

    second_company = Company.find_by(name: "abc_102")
    payments_company_two = Payment.where(company_id: second_company.id)

    puts "Payments for Company 1:"
    payments_company_one.each { |p| puts p.inspect }
    puts "Payments for Company 2:"
    payments_company_two.each { |p| puts p.inspect }

    assert_equal 10, payments_company_one.count
    assert_equal 5, payments_company_two.count
  end
end
