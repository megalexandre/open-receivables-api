class InvoiceCandidatesController < ApplicationController
  def index
    connections = scope_service.call

    total_value = connections.sum('categories.amount_partner + categories.amount_water')
    data = connections.map { |c| serialize_candidate(c) }

    render json: {
      data: data,
      total: data.size,
      total_value: total_value.to_f
    }
  end

  private

  def scope_service = InvoiceCandidates::ScopeService.new(params)

  def serialize_candidate(connection)
    {
      id: connection.id.to_s,
      member_name: connection.member.name,
      address: format_address(connection),
      category: connection.category.name,
      valor_total: (connection.category.amount_partner.to_f + connection.category.amount_water.to_f).round(2),
      hdr_inicial: 0.0
    }
  end

  # Endereço exibido na tabela: "tipo + nome + número" (o número vem da ligação).
  def format_address(connection)
    address = connection.address
    [address.address_type, address.name, connection.number].compact_blank.join(' ')
  end
end
