require 'rails_helper'

RSpec.describe 'GET /addresses/:id', type: :request do
  context 'quando o logradouro existe' do
    it 'retorna 200 com todos os campos' do
      rua = create(:address, address_type: 'Rua', name: 'das Flores', notes: 'Próximo à praça').reload

      get address_path(rua), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'id' => rua.id,
        'address_type' => 'Rua',
        'name' => 'das Flores',
        'notes' => 'Próximo à praça',
        'active' => true
      )
    end
  end

  context 'quando o logradouro não existe' do
    it 'retorna 404' do
      get address_path(id: 999_999), as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq('error' => 'Not found')
    end
  end

  context 'quando o logradouro foi soft-deletado' do
    it 'retorna 404' do
      rua = create(:address)
      rua.soft_delete!

      get address_path(rua), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
