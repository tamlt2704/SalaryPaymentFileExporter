class Payment < ApplicationRecord
  belongs_to :company

  enum :status,  { pending: 0, exported: 1 }
  validates :employee_id, :bank_bsb, :bank_account, :currency, :pay_date, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
end
