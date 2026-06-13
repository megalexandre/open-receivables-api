require 'rails_helper'

RSpec.describe 'PATCH /connections/:id/reactivate', type: :request do
  context 'quando a connection está deletada' do
    let!(:connection) do
      create(:connection, number: '1001').tap(&:soft_delete!)
    end

    it 'reativa a connection e retorna 200' do
      patch reactivate_connection_path(connection), as: :json

      expect(response).to have_http_status(:ok)
      expect(connection.reload.deleted_at).to be_nil
      expect(connection.deleted_by).to be_nil
    end

    it 'retorna a connection com active true no body' do
      patch reactivate_connection_path(connection), as: :json

      body = response.parsed_body
      expect(body['id']).to eq(connection.id)
      expect(body['active']).to eq(true)
    end

    it 'connection volta a aparecer no index' do
      patch reactivate_connection_path(connection), as: :json
      get connections_path, as: :json

      ids = response.parsed_body['data'].map { |c| c['id'] }
      expect(ids).to include(connection.id)
    end
  end

  context 'quando a connection está ativa' do
    let!(:connection) { create(:connection) }

    it 'retorna 200 e mantém a connection ativa (idempotente)' do
      patch reactivate_connection_path(connection), as: :json

      expect(response).to have_http_status(:ok)
      expect(connection.reload.deleted_at).to be_nil
    end
  end

  context 'quando a connection não existe' do
    it 'retorna 404' do
      patch reactivate_connection_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'quando há uma connection ativa com o mesmo address_id + number' do
    let(:address)  { create(:address) }
    let(:member)   { create(:member) }
    let(:category) { create(:category) }

    let!(:deleted_connection) do
      # Criar e deletar primeiro para evitar colisão de validação
      create(:connection, address_id: address.id, number: '1001').tap(&:soft_delete!)
    end

    let!(:active_connection) do
      # Depois criar a connection ativa com o mesmo number
      create(:connection, address_id: address.id, number: '1001', member_id: member.id, category_id: category.id)
    end

    it 'retorna 422 com erro de validação' do
      patch reactivate_connection_path(deleted_connection), as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end

    it 'mantém a connection deletada' do
      patch reactivate_connection_path(deleted_connection), as: :json

      expect(deleted_connection.reload.deleted_at).to be_present
    end

    it 'mantém a connection ativa intacta' do
      patch reactivate_connection_path(deleted_connection), as: :json

      expect(active_connection.reload.deleted_at).to be_nil
    end
  end
end
