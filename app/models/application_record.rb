class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include SoftDeletable

  ERROR_TYPES = {
    taken: "DUPLICATED",
    blank: "REQUIRED",
  }.freeze
  DEFAULT_ERROR_TYPE = "INVALID"

  def self.error_code(_attribute, type)
    feature = model_name.name.underscore.upcase
    "E_#{feature}_#{ERROR_TYPES.fetch(type.to_sym, DEFAULT_ERROR_TYPE)}"
  end
end
