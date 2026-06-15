class InvoiceCandidateSerializer
  def initialize(connection)
    @connection = connection
  end

  def as_json(*)
    {
      id: @connection.id.to_s,
      member_name: @connection.member.name,
      address: format_address,
      category: @connection.category.name,
      valor_total: total_value,
      hdr_inicial: 0.0
    }
  end

  private

  def total_value
    (@connection.category.amount_partner.to_f + @connection.category.amount_water.to_f).round(2)
  end

  # Endereço exibido na tabela: "tipo + nome + número" (o número vem da ligação).
  def format_address
    address = @connection.address
    [address.address_type, address.name, @connection.number].compact_blank.join(' ')
  end
end
