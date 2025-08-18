require "test_helper"

class PaymentsEndToEndTest < ActionDispatch::IntegrationTest
  test "full payment flow: create company, employee, and payment" do
    # Create a company
    post "/companies", params: {
      company: {
        name: "Test Company",
        abn: "12345678901"
      }
    }, as: :json
    assert_response :created
    company_id = JSON.parse(response.body)["id"]

    # Create an employee
    post "/employees", params: {
      employee: {
        company_id: company_id,
        employee_id: "emp999",
        name: "Test Employee",
        bank_bsb: "062000",
        bank_account: "12345678"
      }
    }, as: :json
    assert_response :created
    employee_id = JSON.parse(response.body)["employee_id"]

    # Create a payment
    post "/payments", params: {
      company_id: company_id,
      payments: [
        {
          employee_id: employee_id,
          bank_bsb: "062000",
          bank_account: "12345678",
          amount_cents: 100000,
          currency: "AUD",
          pay_date: Date.today.to_s
        }
      ]
    }, as: :json
    assert_response :created
  end

  test "should not create payment if company does not exist" do
    post "/payments", params: {
      company_id: 999999,
      payments: [
        {
          employee_id: "emp999",
          bank_bsb: "062000",
          bank_account: "12345678",
          amount_cents: 100000,
          currency: "AUD",
          pay_date: Date.today.to_s
        }
      ]
    }, as: :json
    assert_response :bad_request
    assert_includes response.body, "Company not found"
  end

  test "should not create payment if payment is invalid" do
    post "/companies", params: {
      company: {
        name: "Invalid Payment Co",
        abn: "12345678901"
      }
    }, as: :json
    assert_response :created
    company_id = JSON.parse(response.body)["id"]

    post "/employees", params: {
      employee: {
        company_id: company_id,
        employee_id: "emp998",
        name: "Invalid Employee",
        bank_bsb: "062000",
        bank_account: "12345678"
      }
    }, as: :json
    assert_response :created
    employee_id = JSON.parse(response.body)["employee_id"]

    post "/payments", params: {
      company_id: company_id,
      payments: [
        {
          employee_id: employee_id,
          bank_bsb: "badbsb",
          bank_account: "badacct",
          amount_cents: -1,
          currency: "USD",
          pay_date: (Date.today - 1).to_s
        }
      ]
    }, as: :json
    assert_response :bad_request
    assert_includes response.body, "BSB must be 6 digits"
    assert_includes response.body, "Account number must be 6–9 digits"
    assert_includes response.body, "must be greater than 0"
    assert_includes response.body, "is not included in the list"
    assert_includes response.body, "must be greater than or equal to"
  end
end
