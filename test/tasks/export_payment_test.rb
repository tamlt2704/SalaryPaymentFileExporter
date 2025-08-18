require "test_helper"
require "rake"

class ExportPaymentTaskTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def setup
    Rails.application.load_tasks
    @outbox = Rails.application.config_for(:export)["outbox"] || "outbox"
    FileUtils.mkdir_p(Rails.root.join(@outbox))
    Payment.update_all(status: :pending)

    travel_to Date.new(2025, 8, 16)
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join(@outbox))
    Rake::Task["payments:export"].reenable

    travel_back
  end

  test "exports pending payments to file and updates status" do
    travel_to Date.new(2025, 8, 16) do
      payment = payments(:one)
      payment.update!(pay_date: Date.today, status: :pending)
      payment.reload

      assert payment.valid?, payment.errors.full_messages.inspect

      # Ensure only one payment is pending and eligible
      Payment.where.not(id: payment.id).update_all(status: :exported)

      # Debug: print eligible payments
      eligible = Payment.pending.where("pay_date <= ?", Date.today)
      puts "Eligible payments: #{eligible.map(&:id)}"

      assert_output(/Exported 1 payments to/) do
        Rake::Task["payments:export"].invoke
      end

      exported_file = Dir[Rails.root.join(@outbox, "export_*.txt")].first
      assert File.exist?(exported_file), "Export file should exist"

      content = File.read(exported_file)
      assert_includes content, payment.employee_id
      assert_equal "exported", payment.reload.status
    end
  end

  test "does nothing if no pending payments" do
    Payment.update_all(status: :exported)
    assert_output(/No payments to export/) do
      Rake::Task["payments:export"].invoke
    end
  end

  test "rolls back all changes if file move (FTP) fails" do
    travel_to Date.new(2025, 8, 16) do
      payment = payments(:one)
      payment.update!(pay_date: Date.today, status: :pending)
      payment.reload

      # Ensure only one payment is pending and eligible
      Payment.where.not(id: payment.id).update_all(status: :exported)


      # Patch FileUtils.cp to raise an error to simulate FTP failure
      class << FileUtils
        alias_method :orig_cp, :cp
        def cp(*args)
          raise StandardError, "Simulated FTP failure"
        end
      end
      begin
        Rake::Task["payments:export"].invoke
      ensure
        class << FileUtils
          alias_method :cp, :orig_cp
          remove_method :orig_cp
        end
      end

      # Payment status should remain pending, no audit should be created
      assert_equal "pending", payment.reload.status
      assert_equal 0, Audit.where("filepath LIKE ?", "%export_%").count
    end
  end
end
