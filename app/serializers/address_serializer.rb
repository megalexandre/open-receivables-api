class AddressSerializer
  def initialize(address)
    @address = address
  end

  def as_json(*)
    {
      id:           @address.id,
      address_type: @address.address_type,
      name:         @address.name,
      notes:        @address.notes,
      active:       @address.deleted_at.nil?,
    }
  end
end
