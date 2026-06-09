module ErrorResponse
  extend ActiveSupport::Concern

  private

  def render_errors(record)
    errors = record.errors.map do |error|
      code = record.class.error_code(error.attribute, error.type)
      { code: code, field: error.attribute }
    end

    render json: { errors: errors }, status: :unprocessable_entity
  end
end
