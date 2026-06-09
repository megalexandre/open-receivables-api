class Link < ApplicationRecord
belongs_to :address
  belongs_to :member,   foreign_key: :id_pessoa
  belongs_to :category, foreign_key: :id_categoria_socio

  validates :address_id,         presence: true
  validates :id_pessoa, presence: true
  validates :id_categoria_socio, presence: true

  def as_json(options = {})
    {
      'id'              => id.to_s,
      'member_id'       => id_pessoa.to_s,
      'member_name'     => member.name,
      'address_id'      => address_id.to_s,
      'address'         => "#{address.address_type} #{address.name}",
      'active'          => inativo.to_s == "\x00" || inativo.to_s == "0",
      'category_id'     => id_categoria_socio.to_s,
      'category_name'   => category.name,
      'value'           => category.amount_water.to_f + category.amount_partner.to_f,
      'numero'          => numero,
      'datamatricula'   => datamatricula,
      'socio_exclusivo' => !(socio_exclusivo.to_s == "\x00" || socio_exclusivo.to_s == "0"),
    }
  end
end
