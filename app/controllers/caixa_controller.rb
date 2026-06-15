class CaixaController < ApplicationController
  def index
    scope     = scope_service.call
    page      = params.fetch(:page, 1).to_i
    page_size = params.fetch(:pageSize, 50).to_i
    records   = scope.limit(page_size).offset((page - 1) * page_size)

    render json: {
      data: records.map { |inv| CaixaPostingSerializer.new(inv) },
      total: scope.count,
      total_value: scope.sum('COALESCE(invoices.amount_partner, 0) + COALESCE(invoices.amount_water, 0)').to_f,
      page: page,
      pageSize: page_size
    }
  end

  private

  def scope_service = Caixa::ScopeService.new(params)
end
