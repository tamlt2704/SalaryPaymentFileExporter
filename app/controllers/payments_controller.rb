class PaymentsController < ApplicationController
  def index
    payments = Payment.all.order(created_at: :desc)
    render json: payments
  end

  def create
    company = Company.find_by(id: params[:company_id])
    unless company
      render json: { error: "Company not found" }, status: :bad_request and return
    end

    payments = params.require(:payments).map do |p|
      company.payments.build(p.permit(:employee_id, :bank_bsb, :bank_account, :amount_cents, :currency, :pay_date).merge(status: :pending))
    end

    if payments.all?(&:valid?)
      payments.each(&:save!)
      render json: { message: "Created" }, status: :created
    else
      render json: { errors: payments.map(&:errors) }, status: :bad_request
    end
  end
end
