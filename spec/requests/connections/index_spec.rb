require 'rails_helper'

RSpec.describe 'GET /connections', type: :request do
  context 'com conexões no banco' do
    let!(:address)  { create(:address) }
    let!(:member)   { create(:member) }
    let!(:category) { create(:category) }
    let!(:connection) { create(:connection, address_id: address.id, member_id: member.id, category_id: category.id) }

    it 'retorna lista de conexões' do
      get connections_path, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_present
      expect(response.parsed_body['data'].size).to eq(1)
      expect(response.parsed_body['data'][0]['id']).to eq(connection.id)
    end
  end
end
