require 'rails_helper'

RSpec.describe 'GET /members/:id', type: :request do
  context 'quando o membro existe' do
    it 'retorna 200 com todos os campos' do
      membro = create(:member, name: 'Dona Maria', document: '12300000001', member_number: 7)

      get member_path(membro), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'id'            => membro.id,
        'name'          => 'Dona Maria',
        'document'      => '12300000001',
        'member_number' => 7,
        'voter'         => false,
        'active'        => true
      )
    end
  end

  context 'quando o membro não existe' do
    it 'retorna 404' do
      get member_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'quando o membro foi soft-deletado' do
    it 'retorna 404' do
      membro = create(:member)
      membro.soft_delete!

      get member_path(membro), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
