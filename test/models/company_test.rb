require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "Let there be 3 companies" do
    assert_equal 3, Company.all.size
  end
end
