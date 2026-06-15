class InvoiceSerializer
  def initialize(invoice)
    @invoice = invoice
  end

  def as_json(*)
    {
      id: @invoice.id,
      connectionId: @invoice.connection_id,
      memberName: @invoice.connection&.member&.name,
      address: format_address,
      dueDate: @invoice.due_date,
      referenceDate: @invoice.reference_date,
      paidAt: @invoice.paid_at,
      amountPartner: @invoice.amount_partner&.to_f,
      amountWater: @invoice.amount_water&.to_f,
      active: @invoice.deleted_at.nil?,
      createdAt: @invoice.created_at
    }
  end

  private

  # Endereço: "tipo + nome + número" (número vem da ligação).
  def format_address
    conn = @invoice.connection
    return nil if conn.nil?

    addr = conn.address
    [addr&.address_type, addr&.name, conn.number].compact_blank.join(' ')
  end
end
