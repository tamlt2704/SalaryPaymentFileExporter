require "test_helper"


class PaymentTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    travel_to Date.new(2025, 8, 16)
    @company = Company.first
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
      # puts payment.inspect
      unless payment.valid?
        puts "Errors for payment: #{payment.errors.full_messages.join(', ')}"
      end
      assert payment.valid?, "Invalid payment: #{payment.inspect}"
      assert payment.pending?, "Default status should be pending: #{payment.inspect}"
    end

    assert_equal 10, payments_company_one.count
    assert_equal 5, payments_company_two.count
  end

  test "valid payment" do
    payment = Payment.new(
      company: @company,
      employee_id: "emp999",
      bank_bsb: "123456",
      bank_account: "1234567",
      amount_cents: 1000,
      currency: "AUD",
      pay_date: Date.today,
      status: :pending
    )
    assert payment.valid?
  end

  test "invalid without required fields" do
    payment = Payment.new
    refute payment.valid?
    assert_includes payment.errors[:employee_id], "can't be blank"
    assert_includes payment.errors[:bank_bsb], "can't be blank"
    assert_includes payment.errors[:bank_account], "can't be blank"
    assert_includes payment.errors[:currency], "can't be blank"
    assert_includes payment.errors[:pay_date], "can't be blank"
  end

  test "invalid amount_cents less than or equal to 0" do
    payment = Payment.new(
      company: @company,
      employee_id: "emp999",
      bank_bsb: "123456",
      bank_account: "1234567",
      amount_cents: 0,
      currency: "AUD",
      pay_date: Date.today
    )
    refute payment.valid?
    assert_includes payment.errors[:amount_cents], "must be greater than 0"
  end

  test "invalid bank_bsb format" do
    payment = Payment.new(
      company: @company,
      employee_id: "emp999",
      bank_bsb: "12345",
      bank_account: "1234567",
      amount_cents: 1000,
      currency: "AUD",
      pay_date: Date.today
    )
    refute payment.valid?
    assert_includes payment.errors[:bank_bsb], "BSB must be 6 digits"
  end

  test "invalid bank_account format" do
    payment = Payment.new(
      company: @company,
      employee_id: "emp999",
      bank_bsb: "123456",
      bank_account: "12345",
      amount_cents: 1000,
      currency: "AUD",
      pay_date: Date.today
    )
    refute payment.valid?
    assert_includes payment.errors[:bank_account], "Account number must be 6–9 digits"
  end

  test "invalid currency" do
    payment = Payment.new(
      company: @company,
      employee_id: "emp999",
      bank_bsb: "123456",
      bank_account: "1234567",
      amount_cents: 1000,
      currency: "USD",
      pay_date: Date.today
    )
    refute payment.valid?
    assert_includes payment.errors[:currency], "is not included in the list"
  end

  test "invalid pay_date in the past" do
    payment = Payment.new(
      company: @company,
      employee_id: "emp999",
      bank_bsb: "123456",
      bank_account: "1234567",
      amount_cents: 1000,
      currency: "AUD",
      pay_date: Date.yesterday
    )
    refute payment.valid?
    assert_includes payment.errors[:pay_date], "must be greater than or equal to #{Date.today}"
  end

  test "combination of multiple invalid fields" do
    payment = Payment.new(
      company: @company,
      employee_id: "",
      bank_bsb: "abc123",
      bank_account: "123",
      amount_cents: -50,
      currency: "EUR",
      pay_date: Date.yesterday
    )
    refute payment.valid?
    assert_includes payment.errors[:employee_id], "can't be blank"
    assert_includes payment.errors[:bank_bsb], "BSB must be 6 digits"
    assert_includes payment.errors[:bank_account], "Account number must be 6–9 digits"
    assert_includes payment.errors[:amount_cents], "must be greater than 0"
    assert_includes payment.errors[:currency], "is not included in the list"
    assert_includes payment.errors[:pay_date], "must be greater than or equal to #{Date.today}"
  end
end
