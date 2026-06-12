require 'rails_helper'

RSpec.describe 'PATCH /addresses/:id/reactivate', type: :request do
  context 'quando o logradouro está deletado' do
    let!(:rua) { create(:address, name: 'Logradouro Antigo').tap(&:soft_delete!) }

    it 'reativa o logradouro e retorna 200' do
      patch reactivate_address_path(rua), as: :json

      expect(response).to have_http_status(:ok)
      expect(rua.reload.deleted_at).to be_nil
      expect(rua.deleted_by).to be_nil
    end

    it 'retorna o logradouro com active true no body' do
      patch reactivate_address_path(rua), as: :json

      body = response.parsed_body
      expect(body['id']).to eq(rua.id)
      expect(body['active']).to eq(true)
    end

    it 'logradouro volta a aparecer no index' do
      patch reactivate_address_path(rua), as: :json
      get addresses_path, as: :json

      ids = response.parsed_body['data'].map { |a| a['id'] }
      expect(ids).to include(rua.id)
    end
  end

  context 'quando o logradouro está ativo' do
    let!(:rua) { create(:address) }

    it 'retorna 200 e mantém o logradouro ativo (idempotente)' do
      patch reactivate_address_path(rua), as: :json

      expect(response).to have_http_status(:ok)
      expect(rua.reload.deleted_at).to be_nil
    end
  end

  context 'quando o logradouro não existe' do
    it 'retorna 404' do
      patch reactivate_address_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
