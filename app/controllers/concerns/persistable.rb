module Persistable
  extend ActiveSupport::Concern

  private

  def save_and_respond(record, status: :ok, serializer: nil)
    if record.save
      render json: (serializer ? serializer.new(record) : record), status: status
    else
      render_errors(record)
    end
  end
end
