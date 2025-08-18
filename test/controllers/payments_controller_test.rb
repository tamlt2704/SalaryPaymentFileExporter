require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should not create payment batch if any payment is invalid" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [
        {
          employee_id: "emp001",
          bank_bsb: "062000",
          bank_account: "12345678",
          amount_cents: 250000,
          currency: "AUD",
          pay_date: Date.today.to_s
        },
        {
          employee_id: "",
          bank_bsb: "abc123",
          bank_account: "123",
          amount_cents: -50,
          currency: "EUR",
          pay_date: (Date.today - 1).to_s
        }
      ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "can't be blank"
    assert_includes response.body, "BSB must be 6 digits"
    assert_includes response.body, "Account number must be 6–9 digits"
    assert_includes response.body, "must be greater than 0"
    assert_includes response.body, "is not included in the list"
    assert_includes response.body, "must be greater than or equal to"
  end
  setup do
    @company = companies(:one)
  end

  test "should create payment batch" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "emp001",
        bank_bsb: "062000",
        bank_account: "12345678",
        amount_cents: 250000,
        currency: "AUD",
        pay_date: Date.today.to_s
      } ]
    }, as: :json

    assert_response :created
  end

  test "should not create payment with missing required fields" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        bank_bsb: "062000",
        bank_account: "12345678",
        amount_cents: 250000,
        currency: "AUD",
        pay_date: Date.today.to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "can't be blank"
  end

  test "should not create payment with invalid bank_bsb" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "emp001",
        bank_bsb: "06200",
        bank_account: "12345678",
        amount_cents: 250000,
        currency: "AUD",
        pay_date: Date.today.to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "BSB must be 6 digits"
  end

  test "should not create payment with invalid bank_account" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "emp001",
        bank_bsb: "062000",
        bank_account: "12345",
        amount_cents: 250000,
        currency: "AUD",
        pay_date: Date.today.to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "Account number must be 6–9 digits"
  end

  test "should not create payment with invalid amount_cents" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "emp001",
        bank_bsb: "062000",
        bank_account: "12345678",
        amount_cents: 0,
        currency: "AUD",
        pay_date: Date.today.to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "must be greater than 0"
  end

  test "should not create payment with invalid currency" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "emp001",
        bank_bsb: "062000",
        bank_account: "12345678",
        amount_cents: 250000,
        currency: "USD",
        pay_date: Date.today.to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "is not included in the list"
  end

  test "should not create payment with pay_date in the past" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "emp001",
        bank_bsb: "062000",
        bank_account: "12345678",
        amount_cents: 250000,
        currency: "AUD",
        pay_date: (Date.today - 1).to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "must be greater than or equal to"
  end

  test "should not create payment with multiple invalid fields" do
    post "/payments", params: {
      company_id: @company.id,
      payments: [ {
        employee_id: "",
        bank_bsb: "abc123",
        bank_account: "123",
        amount_cents: -50,
        currency: "EUR",
        pay_date: (Date.today - 1).to_s
      } ]
    }, as: :json

    assert_response :bad_request
    assert_includes response.body, "can't be blank"
    assert_includes response.body, "BSB must be 6 digits"
    assert_includes response.body, "Account number must be 6–9 digits"
    assert_includes response.body, "must be greater than 0"
    assert_includes response.body, "is not included in the list"
    assert_includes response.body, "must be greater than or equal to"
  end
end
