class AuditsController < ApplicationController
  def index
    audits = Audit.order(exported_at: :desc)
    render json: audits
  end
end
