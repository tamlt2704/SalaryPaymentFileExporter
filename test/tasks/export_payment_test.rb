require "test_helper"
require "rake"

class ExportPaymentTaskTest < ActiveSupport::TestCase
  def setup
    Rails.application.load_tasks
    @outbox = Rails.application.config_for(:export)["outbox"] || "outbox"
    FileUtils.mkdir_p(Rails.root.join(@outbox))
    Payment.update_all(status: :pending)
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join(@outbox))
    Rake::Task["payments:export"].reenable
  end

  test "exports pending payments to file and updates status" do
    payment = payments(:one)
    payment.update!(pay_date: Date.today, status: :pending)

    # Ensure only one payment is pending and eligible
    Payment.where.not(id: payment.id).update_all(status: :exported)

    assert_difference -> { Audit.count }, 1 do
      assert_output(/Exported 1 payments to/) do
        Rake::Task["payments:export"].invoke
      end
    end

    exported_file = Dir[Rails.root.join(@outbox, "export_*.txt")].first
    assert File.exist?(exported_file), "Export file should exist"

    content = File.read(exported_file)
    assert_includes content, payment.employee_id
    assert_equal "exported", payment.reload.status
  end

  test "does nothing if no pending payments" do
    Payment.update_all(status: :exported)
    assert_output(/No payments to export/) do
      Rake::Task["payments:export"].invoke
    end
  end
end
