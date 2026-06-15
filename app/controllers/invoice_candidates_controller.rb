class InvoiceCandidatesController < ApplicationController
  def index
    connections = scope_service.call

    render json: {
      data: connections.map { |c| InvoiceCandidateSerializer.new(c) },
      total: connections.size,
      total_value: connections.sum('categories.amount_partner + categories.amount_water').to_f
    }
  end

  private

  def scope_service = InvoiceCandidates::ScopeService.new(params)
end
