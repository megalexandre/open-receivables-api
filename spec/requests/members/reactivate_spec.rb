require 'rails_helper'

RSpec.describe 'PATCH /members/:id/reactivate', type: :request do
  context 'quando o membro está deletado' do
    let!(:membro) { create(:member, name: 'Sócio Antigo').tap(&:soft_delete!) }

    it 'reativa o membro e retorna 200' do
      patch reactivate_member_path(membro), as: :json

      expect(response).to have_http_status(:ok)
      expect(membro.reload.deleted_at).to be_nil
      expect(membro.deleted_by).to be_nil
    end

    it 'retorna o membro com active true no body' do
      patch reactivate_member_path(membro), as: :json

      body = response.parsed_body
      expect(body['id']).to eq(membro.id)
      expect(body['active']).to eq(true)
    end

    it 'membro volta a aparecer no index' do
      patch reactivate_member_path(membro), as: :json
      get members_path, as: :json

      ids = response.parsed_body['data'].map { |m| m['id'] }
      expect(ids).to include(membro.id)
    end
  end

  context 'quando o membro está ativo' do
    let!(:membro) { create(:member) }

    it 'retorna 200 e mantém o membro ativo (idempotente)' do
      patch reactivate_member_path(membro), as: :json

      expect(response).to have_http_status(:ok)
      expect(membro.reload.deleted_at).to be_nil
    end
  end

  context 'quando o membro não existe' do
    it 'retorna 404' do
      patch reactivate_member_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
