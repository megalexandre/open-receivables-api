require 'rails_helper'

RSpec.describe 'DELETE /members/:id', type: :request do
  let!(:membro) { create(:member) }

  it 'faz soft delete e retorna 204' do
    delete member_path(membro), as: :json

    expect(response).to have_http_status(:no_content)
    expect(Member.unscoped.find(membro.id).deleted_at).to be_present
  end

  it 'não aparece mais no index após deletar' do
    delete member_path(membro), as: :json
    get members_path, as: :json

    ids = response.parsed_body['data'].map { |m| m['id'] }
    expect(ids).not_to include(membro.id)
  end

  context 'quando o membro não existe' do
    it 'retorna 404' do
      delete member_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
