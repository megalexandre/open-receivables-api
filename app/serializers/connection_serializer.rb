class ConnectionSerializer
  def initialize(connection)
    @connection = connection
  end

  def as_json(*)
    {
      id:                 @connection.id,
      member_id:          @connection.member_id,
      member_name:        @connection.member.name,
      address_id:         @connection.address_id,
      address:            "#{@connection.address.address_type} #{@connection.address.name}",
      active:             @connection.deleted_at.nil?,
      category_id:        @connection.category_id,
      category_name:      @connection.category.name,
      value:              @connection.category.amount_water.to_f + @connection.category.amount_partner.to_f,
      number:             @connection.number,
      registration_date:  @connection.registration_date,
      partner_exclusive:  @connection.partner_exclusive,
    }
  end
end
