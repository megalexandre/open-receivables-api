class CategorySerializer
  def initialize(category)
    @category = category
  end

  def as_json(*)
    @category.attributes.merge(
      'amount_water'  => @category.amount_water_money.to_d.to_f,
      'amount_partner' => @category.amount_partner_money.to_d.to_f,
      'active'        => @category.deleted_at.nil?,
    )
  end
end
