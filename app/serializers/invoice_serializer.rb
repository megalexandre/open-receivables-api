class InvoiceSerializer
  def initialize(invoice)
    @invoice = invoice
  end

  def as_json(*)
    {
      id: @invoice.id,
      connectionId: @invoice.connection_id,
      dueDate: @invoice.due_date,
      referenceDate: @invoice.reference_date,
      paidAt: @invoice.paid_at,
      amountPartner: @invoice.amount_partner,
      amountWater: @invoice.amount_water,
      active: @invoice.deleted_at.nil?,
      createdAt: @invoice.created_at
    }
  end
end
