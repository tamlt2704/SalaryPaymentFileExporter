require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "Let there be 3 companies" do
    assert_equal 3, Company.count
  end

  test "find by name" do
    first_company = Company.find_by(name: "abc_101")
    refute_nil first_company
  end

  test "create company and able to save" do
    dummy_company = Company.create(name: "dummy_101")
    refute_nil dummy_company.id

    assert_equal true, Company.exists?(name: "dummy_101")
  end
end
