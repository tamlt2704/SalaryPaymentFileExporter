class CompaniesController < ApplicationController
  def index
    @companies = Company.all

    # Filter by name (partial match)
    if params[:name].present?
      @companies = @companies.where("name ILIKE ?", "%#{params[:name]}%")
    end

    # Filter by ID
    if params[:id].present?
      @companies = @companies.where(id: params[:id])
    end

    # Pagination
    page     = params.fetch(:page, 1).to_i
    per_page = params.fetch(:per_page, 10).to_i
    @companies = @companies.order(:name).offset((page - 1) * per_page).limit(per_page)

    render json: {
      companies: @companies,
      page: page,
      per_page: per_page,
      total: Company.count
    }
  end

  def create
    company = Company.new(company_params)
    if company.save
      render json: company, status: :created
    else
      render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end
end
