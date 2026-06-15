class CaixaPostingSerializer
  def initialize(invoice)
    @invoice = invoice
  end

  def as_json(*)
    {
      'id'             => @invoice.id.to_s,
      'member_name'    => @invoice.connection&.member&.name.to_s,
      'number'         => @invoice.connection&.number.to_s,
      'payment_date'   => @invoice.paid_at&.to_date&.iso8601,
      'payment_method' => @invoice.payment_method.presence || 'DINHEIRO',
      'value'          => (@invoice.amount_partner.to_f + @invoice.amount_water.to_f).round(2)
    }
  end
end
