class PaymentsController < ApplicationController
  def create
    company = Company.find_by(id: params[:company_id])
    unless company
      render json: { error: "Company not found" }, status: :not_found and return
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
