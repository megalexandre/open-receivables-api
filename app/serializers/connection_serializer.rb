class ConnectionSerializer
  def initialize(connection)
    @connection = connection
  end

  def as_json(*)
    {
      id:                 @connection.id,
      memberId:           @connection.member_id,
      memberName:         @connection.member.name,
      addressId:          @connection.address_id,
      address:            "#{@connection.address.address_type} #{@connection.address.name}",
      active:             @connection.deleted_at.nil?,
      categoryId:         @connection.category_id,
      categoryName:       @connection.category.name,
      value:              @connection.category.amount_water.to_f + @connection.category.amount_partner.to_f,
      number:             @connection.number,
      registrationDate:   @connection.registration_date,
      partnerExclusive:   @connection.partner_exclusive,
    }
  end
end
