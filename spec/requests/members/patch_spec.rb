require 'rails_helper'

RSpec.describe 'PATCH /members/:id', type: :request do
  let!(:membro) { create(:member, name: 'Nome Original') }

  context 'com dados válidos' do
    it 'atualiza o nome e retorna 200' do
      patch member_path(membro), params: { member: { name: 'Nome Novo' } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(membro.reload.name).to eq('Nome Novo')
    end

    it 'retorna o membro atualizado com os campos esperados no body' do
      patch member_path(membro), params: { member: { name: 'Nome Novo' } }, as: :json

      body = response.parsed_body
      expect(body).to include('id', 'name', 'document', 'member_number', 'voter')
      expect(body['name']).to eq('Nome Novo')
    end

    it 'atualiza o campo voter e retorna voter atualizado' do
      patch member_path(membro), params: { member: { voter: true } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(membro.reload.voter).to eq(true)
      expect(response.parsed_body['voter']).to eq(true)
    end

    it 'limpa formatação do document no update' do
      patch member_path(membro), params: { member: { document: '444.555.666-77' } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(membro.reload.document).to eq('44455566677')
    end
  end

  context 'com document duplicado' do
    let!(:outro) { create(:member, document: '99988877766') }

    it 'retorna 422' do
      patch member_path(membro), params: { member: { document: outro.document } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna código de erro E_MEMBER_DUPLICATED com field document' do
      patch member_path(membro), params: { member: { document: outro.document } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors).to be_an(Array)
      expect(errors.first['code']).to eq('E_MEMBER_DUPLICATED')
      expect(errors.first['field']).to eq('document')
    end

    it 'retorna mensagem avisando a duplicação' do
      patch member_path(membro), params: { member: { document: outro.document } }, as: :json

      error = response.parsed_body['errors'].find { |e| e['code'] == 'E_MEMBER_DUPLICATED' }
      expect(error['message']).to eq('já existe um sócio cadastrado com este documento')
    end

    it 'retorna 422 ao usar document de membro deletado (unicidade absoluta)' do
      deletado = create(:member, document: '55544433322').tap(&:soft_delete!)

      patch member_path(membro), params: { member: { document: deletado.document } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors'].first['code']).to eq('E_MEMBER_DUPLICATED')
    end
  end

  context 'quando o membro não existe' do
    it 'retorna 404' do
      patch member_path(id: 0), params: { member: { name: 'X' } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
