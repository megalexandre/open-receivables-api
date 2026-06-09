class Address < ApplicationRecord
  has_many :links, foreign_key: :address_id

  validates :name, presence: true
  validates :address_type, presence: true

  def as_json(options = {})
    super(options).merge("id" => id.to_s)
  end

end
