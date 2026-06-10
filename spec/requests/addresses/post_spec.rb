require 'rails_helper'

RSpec.describe 'POST /addresses', type: :request do
  let(:valid_params) do
    {
      address: {
        address_type: 'Rua',
        name:         'das Flores'
      }
    }
  end

  context 'com dados válidos' do
    it 'cria logradouro e retorna 201' do
      expect {
        post addresses_path, params: valid_params, as: :json
      }.to change(Address, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'permite tipo e nome iguais aos de um logradouro deletado' do
      create(:address, address_type: 'Rua', name: 'das Flores', deleted_at: Time.current)

      expect {
        post addresses_path, params: valid_params, as: :json
      }.to change(Address, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'permite o mesmo nome em address_type diferente' do
      create(:address, address_type: 'Avenida', name: 'das Flores')

      post addresses_path, params: valid_params, as: :json

      expect(response).to have_http_status(:created)
    end
  end

  context 'com tipo e nome duplicados' do
    it 'retorna 422 com o code E_ADDRESS_DUPLICATED' do
      create(:address, address_type: 'Rua', name: 'das Flores')

      expect {
        post addresses_path, params: valid_params, as: :json
      }.not_to change(Address, :count)

      expect(response).to have_http_status(:unprocessable_content)

      error = response.parsed_body['errors'].find { |e| e['code'] == 'E_ADDRESS_DUPLICATED' }
      expect(error).to be_present
      expect(error['field']).to eq('name')
    end
  end
end
