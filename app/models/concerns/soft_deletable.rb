module SoftDeletable
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }

    before_create { self.created_at ||= Time.current }
    before_save   { self.updated_at = Time.current }
  end

  def soft_delete!(deleted_by: nil)
    update_columns(deleted_at: Time.current, deleted_by: deleted_by)
  end

  def reactivate!
    update_columns(deleted_at: nil, deleted_by: nil)
  end
end
