require 'rails_helper'

RSpec.describe 'POST /connections', type: :request do
  let(:address)  { create(:address) }
  let(:member)   { create(:member) }
  let(:category) { create(:category) }

  let(:valid_params) do
    {
      connection: {
        address_id:        address.id,
        member_id:         member.id,
        category_id:       category.id,
        number:            '1001',
        registration_date: Date.current,
        partner_exclusive: false
      }
    }
  end

  context 'com dados válidos' do
    it 'cria connection e retorna 201' do
      expect {
        post connections_path, params: valid_params, as: :json
      }.to change(Connection, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  context 'com address_id + numero duplicados (ambos ativos)' do
    before do
      create(:connection, address_id: address.id, number: '1001')
    end

    it 'retorna 422 com erro de validação' do
      expect {
        post connections_path, params: valid_params, as: :json
      }.not_to change(Connection, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end

  context 'com address_id + numero duplicados mas o existente deletado' do
    before do
      conn = create(:connection, address_id: address.id, number: '1001')
      conn.soft_delete!
    end

    it 'permite criar nova connection ativa' do
      expect {
        post connections_path, params: valid_params, as: :json
      }.to change(Connection, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  context 'com address_id + numero duplicados e ambos deletados' do
    before do
      conn = create(:connection, address_id: address.id, number: '1001')
      conn.soft_delete!
    end

    it 'permite múltiplos registros deletados com mesmo address_id + numero' do
      conn = create(:connection, address_id: address.id, member_id: member.id, category_id: category.id, number: '1001')
      conn.soft_delete!

      expect(Connection.count).to eq(0) # Nenhum ativo (ambos deletados)
      expect(Connection.unscoped.count).to eq(2) # 2 no total (ambos deletados)
    end
  end
end
