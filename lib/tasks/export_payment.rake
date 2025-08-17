namespace :payments do
  desc "Export pending payments to bank file"
  task export: :environment do
    today = Date.today
    payments = Payment.pending.where("pay_date <= ?", today)
    payment_count = payments.count

    if payment_count == 0
      puts "No payments to export"
      next
    end

    out_dir = Rails.application.config_for(:export)["outbox"] || "outbox"
    FileUtils.mkdir_p(Rails.root.join(out_dir)) unless Dir.exist?(Rails.root.join(out_dir))
    filename = "export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt"
    filepath = Rails.root.join(out_dir, filename)
    Rails.logger.info "Exporting #{payment_count} payments to #{filepath}"
    File.open(filepath, "w") do |file|
      payments.each do |p|
        file.puts [
          p.company_id,
          p.employee_id,
          p.bank_bsb,
          p.bank_account,
          p.amount_cents,
          p.currency,
          p.pay_date
        ].join(",")
      end
    end

    Audit.create!(filepath: filepath, exported_at: Time.now)
    payments.update_all(status: :exported)
    puts "Exported #{payment_count} payments to #{filepath}"
  end
end
