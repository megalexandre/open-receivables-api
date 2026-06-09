module Persistable
  extend ActiveSupport::Concern

  private

  def save_and_respond(record, status: :ok)
    if record.save
      render json: record, status: status
    else
      render_errors(record)
    end
  end
end
