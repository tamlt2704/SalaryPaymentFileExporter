require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "Let there be 3 companies" do
    assert_equal 3, Company.all.size
  end

  test "find by id" do
    first_company = Company.find_by(name: "abc_101")
    expect(value).not_to be_nil
  end
end
