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
end
