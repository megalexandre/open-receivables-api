require 'rails_helper'

RSpec.describe 'PATCH /addresses/:id', type: :request do
  context 'com dados válidos' do
    it 'atualiza logradouro e retorna 200' do
      address = create(:address)

      patch address_path(address), params: { address: { name: 'Atualizada' } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(address.reload.name).to eq('Atualizada')
    end
  end

  context 'com tipo e nome duplicados' do
    it 'retorna 422 com o code E_ADDRESS_DUPLICATED' do
      create(:address, address_type: 'Rua', name: 'das Flores')
      other = create(:address, address_type: 'Avenida', name: 'Brasil')

      patch address_path(other), params: { address: { address_type: 'Rua', name: 'das Flores' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)

      error = response.parsed_body['errors'].find { |e| e['code'] == 'E_ADDRESS_DUPLICATED' }
      expect(error).to be_present
    end
  end
end
