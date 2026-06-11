require 'rails_helper'

RSpec.describe 'POST /members', type: :request do
  context 'com dados válidos' do
    it 'cria membro com CPF (11 dígitos) e retorna 201' do
      post members_path, params: { member: { name: 'Ana Lima', document: '12345678901', member_number: 1 } }, as: :json

      expect(response).to have_http_status(:created)
    end

    it 'cria membro com CNPJ (14 dígitos) e retorna 201' do
      post members_path, params: { member: { name: 'Empresa Rural', document: '12345678000195' } }, as: :json

      expect(response).to have_http_status(:created)
    end

    it 'salva document sem formatação (remove pontos e traços)' do
      post members_path, params: { member: { name: 'Sócio X', document: '444.555.666-77' } }, as: :json

      expect(response).to have_http_status(:created)
      expect(Member.last.document).to eq('44455566677')
    end

    it 'retorna os campos id, name, document, member_number e voter no body' do
      post members_path, params: { member: { name: 'Sócio Shape', document: '12345678901', member_number: 42 } }, as: :json

      body = response.parsed_body
      expect(body).to include(
        'name'          => 'Sócio Shape',
        'document'      => '12345678901',
        'member_number' => 42,
        'voter'         => false
      )
      expect(body['id']).to be_present
    end

    it 'retorna voter: true quando criado com voter: true' do
      post members_path, params: { member: { name: 'Eleitor', document: '12345678901', voter: true } }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['voter']).to eq(true)
    end
  end

  context 'com dados inválidos' do
    it 'retorna 422 sem nome' do
      post members_path, params: { member: { document: '12345678901' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna errors com field name e código E_MEMBER_REQUIRED ao omitir nome' do
      post members_path, params: { member: { document: '12345678901' } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors).to be_an(Array)
      expect(errors.first['field']).to eq('name')
      expect(errors.first['code']).to eq('E_MEMBER_REQUIRED')
    end

    it 'retorna 422 sem document' do
      post members_path, params: { member: { name: 'Sócio' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna errors com field document ao omitir document' do
      post members_path, params: { member: { name: 'Sócio' } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors.map { |e| e['field'] }).to include('document')
    end

    it 'retorna 422 com document menor que 11 dígitos' do
      post members_path, params: { member: { name: 'Sócio', document: '1234567' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna errors com field document quando document é muito curto' do
      post members_path, params: { member: { name: 'Sócio', document: '1234567' } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors.map { |e| e['field'] }).to include('document')
    end

    it 'retorna 422 com document maior que 14 dígitos' do
      post members_path, params: { member: { name: 'Sócio', document: '123456789012345' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna errors com field document quando document é muito longo' do
      post members_path, params: { member: { name: 'Sócio', document: '123456789012345' } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors.map { |e| e['field'] }).to include('document')
    end
  end

  context 'com document duplicado em membro ativo' do
    let!(:existente) { create(:member, document: '12345678901') }

    it 'retorna 422' do
      post members_path, params: { member: { name: 'Outro Nome', document: '12345678901' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'não cria um novo registro' do
      expect {
        post members_path, params: { member: { name: 'Outro Nome', document: '12345678901' } }, as: :json
      }.not_to change(Member, :count)
    end

    it 'retorna código de erro E_MEMBER_DUPLICATED com field document' do
      post members_path, params: { member: { name: 'Outro Nome', document: '12345678901' } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors).to be_an(Array)
      expect(errors.first['code']).to eq('E_MEMBER_DUPLICATED')
      expect(errors.first['field']).to eq('document')
    end

    it 'retorna mensagem avisando a duplicação' do
      post members_path, params: { member: { name: 'Outro Nome', document: '12345678901' } }, as: :json

      error = response.parsed_body['errors'].find { |e| e['code'] == 'E_MEMBER_DUPLICATED' }
      expect(error['message']).to eq('já existe um sócio cadastrado com este documento')
    end
  end

  context 'com document de membro deletado' do
    let!(:deletado) { create(:member, name: 'Sócio Antigo', document: '12345678901').tap(&:soft_delete!) }

    it 'retorna 422 com código E_MEMBER_DUPLICATED' do
      post members_path, params: { member: { name: 'Novo Sócio', document: '12345678901' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      error = response.parsed_body['errors'].first
      expect(error['code']).to eq('E_MEMBER_DUPLICATED')
      expect(error['field']).to eq('document')
    end

    it 'não cria um novo registro' do
      expect {
        post members_path, params: { member: { name: 'Novo Sócio', document: '12345678901' } }, as: :json
      }.not_to change(Member.unscoped, :count)
    end

    it 'não altera nem reativa o membro deletado' do
      post members_path, params: { member: { name: 'Novo Sócio', document: '12345678901', voter: true } }, as: :json

      deletado.reload
      expect(deletado.deleted_at).to be_present
      expect(deletado.name).to eq('Sócio Antigo')
    end

    it 'retorna 422 mesmo quando o document chega formatado' do
      post members_path, params: { member: { name: 'Novo Sócio', document: '123.456.789-01' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(deletado.reload.deleted_at).to be_present
    end
  end
end
