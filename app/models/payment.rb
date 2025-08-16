class Payment < ApplicationRecord
  belongs_to :company
  enum :status,  { pending: 0, exported: 1 }

  validates :employee_id, :bank_bsb, :bank_account, :currency, :pay_date, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
  validates :bank_bsb, format: { with: /\A\d{6}\z/, message: "BSB must be 6 digits" }
  validates :bank_account, format: { with: /\A\d{6,9}\z/, message: "Account number must be 6–9 digits" }
  validates :currency, inclusion: { in: [ "AUD" ] }
  validates :pay_date, comparison: { greater_than_or_equal_to: -> { Date.today } }
end
