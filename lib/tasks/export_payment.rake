namespace :payments do
  desc "Export pending payments to bank file"
  task export: :environment do
    today = Date.today
    payments = Payment.pending.where("pay_date <= ?", today)

    return puts "No payments to export" if payments.empty?

    out_dir = Rails.application.config_for(:export)["outbox"] || "outbox"
    filename = "export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.txt"
    filepath = Rails.root.join(out_dir, filename)

    File.open(filepath, "w") do |file|
      payments.each do |p|
        file.puts [ p.company_id, p.employee_id, p.bank_bsb, p.bank_account,
                   p.amount_cents, p.currency, p.pay_date ].join(", ")
      end
    end

    Audit.create!(filepath: filepath, exported_at: Time.now)
    payments.update_all(status: :exported)
    puts "Exported #{payments.count} payments to #{filepath}"
  end
end
