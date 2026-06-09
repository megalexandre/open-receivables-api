module Destroyable
  extend ActiveSupport::Concern

  def destroy
    resource.soft_delete!
    head :no_content
  end
end
