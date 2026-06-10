require 'rails_helper'

RSpec.describe 'DELETE /addresses/:id', type: :request do
  it 'faz soft delete e retorna 204' do
    address = create(:address)

    delete address_path(address), as: :json

    expect(response).to have_http_status(:no_content)
    expect(Address.unscoped.find(address.id).deleted_at).to be_present
  end
end
