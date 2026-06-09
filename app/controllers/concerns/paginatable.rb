module Paginatable
  extend ActiveSupport::Concern

  private

  def paginate(scope, serializer: nil)
    total = scope.count
    scope = apply_sort(scope)
    pagy, records = pagy(scope, limit: params.fetch(:pageSize, params.fetch(:limit, 20)).to_i)
    data = serializer ? records.map { |r| serializer.new(r) } : records
    { data: data, pagination: pagy_metadata_response(pagy).merge(total: total) }
  end

  def sort_direction
    params[:sort_order] == "desc" ? :desc : :asc
  end
end
