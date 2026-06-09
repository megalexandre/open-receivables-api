class ApplicationController < ActionController::API
  include Pagy::Backend
  include ErrorResponse

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def pagy_metadata_response(pagy)
    {
      current_page: pagy.page,
      total_pages: pagy.pages,
      total_count: pagy.count,
      per_page: pagy.limit
    }
  end

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end
end
