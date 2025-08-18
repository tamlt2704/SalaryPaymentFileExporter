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
    ftp_dir = Rails.application.config_for(:export)["ftpbox"] || "ftpbox"
    FileUtils.mkdir_p(Rails.root.join(out_dir)) unless Dir.exist?(Rails.root.join(out_dir))
    FileUtils.mkdir_p(Rails.root.join(ftp_dir)) unless Dir.exist?(Rails.root.join(ftp_dir))
    filename = "export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt"
    filepath = Rails.root.join(out_dir, filename)
    ftp_path = Rails.root.join(ftp_dir, filename)
    Rails.logger.info "Exporting #{payment_count} payments to #{filepath}"

    ActiveRecord::Base.transaction do
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

      begin
        FileUtils.cp(filepath, ftp_path)
        puts "Exported #{payment_count} payments to #{ftp_path} (simulated FTP)"
      rescue => e
        Rails.logger.error "Failed to move file to FTP folder: #{e.message}"
        raise ActiveRecord::Rollback, "FTP move failed, rolling back export"
      end
    end
  end
end
