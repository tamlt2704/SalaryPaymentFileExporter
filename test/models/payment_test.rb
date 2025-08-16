require "test_helper"


class PaymentTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    travel_to Date.new(2025, 8, 16)
  end

  teardown do
    travel_back
  end

  test "the truth" do
    first_company = Company.find_by(name: "abc_101")
    payments_company_one = Payment.where(company_id: first_company.id)

    second_company = Company.find_by(name: "abc_102")
    payments_company_two = Payment.where(company_id: second_company.id)

    all_payments = Payment.all
    all_payments.each do |payment|
      puts payment.inspect
      unless payment.valid?
        puts "Errors for payment: #{payment.errors.full_messages.join(', ')}"
      end
      assert payment.valid?, "Invalid payment: #{payment.inspect}"
      assert payment.pending?, "Default status should be pending: #{payment.inspect}"
    end

    assert_equal 10, payments_company_one.count
    assert_equal 5, payments_company_two.count
  end
end
