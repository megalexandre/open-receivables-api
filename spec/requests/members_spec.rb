require 'rails_helper'

RSpec.describe 'Members', type: :request do
  let(:json_headers) { { 'Accept' => 'application/json' } }

  describe 'POST /members' do

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

      it 'retorna errors com field name e código E_2_0 ao omitir nome' do
        post members_path, params: { member: { document: '12345678901' } }, as: :json

        errors = response.parsed_body['errors']
        expect(errors).to be_an(Array)
        expect(errors.first['field']).to eq('name')
        expect(errors.first['code']).to eq('E_2_0')
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

      it 'retorna código de erro E_2_1 com field document' do
        post members_path, params: { member: { name: 'Outro Nome', document: '12345678901' } }, as: :json

        errors = response.parsed_body['errors']
        expect(errors).to be_an(Array)
        expect(errors.first['code']).to eq('E_2_1')
        expect(errors.first['field']).to eq('document')
      end
    end

    context 'com document de membro deletado' do
      let!(:deletado) { create(:member, document: '12345678901').tap(&:soft_delete!) }

      it 'permite criar novo membro com o mesmo document' do
        post members_path, params: { member: { name: 'Novo Sócio', document: '12345678901' } }, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'cria o registro no banco' do
        expect {
          post members_path, params: { member: { name: 'Novo Sócio', document: '12345678901' } }, as: :json
        }.to change(Member, :count).by(1)
      end
    end
  end

  describe 'GET /members' do
    let!(:ana)    { create(:member, name: 'Ana Lima',    document: '11100000001', member_number: 3) }
    let!(:beto)   { create(:member, name: 'Beto Souza',  document: '22200000002', member_number: 1) }
    let!(:carlos) { create(:member, name: 'Carlos Neto', document: '33300000003', member_number: 2) }

    it 'retorna todos os membros' do
      get members_path, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].map { |m| m['name'] })
        .to contain_exactly('Ana Lima', 'Beto Souza', 'Carlos Neto')
    end

    it 'cada item do array data contém os campos esperados' do
      get members_path, headers: json_headers

      item = response.parsed_body['data'].first
      expect(item.keys).to match_array(%w[id name document member_number voter])
    end

    it 'retorna estrutura de paginação no body' do
      get members_path, headers: json_headers

      pagination = response.parsed_body['pagination']
      expect(pagination).to include('current_page', 'total_pages', 'total_count', 'per_page')
      expect(pagination['current_page']).to eq(1)
      expect(pagination['total_count']).to eq(3)
    end

    it 'respeita o pageSize informado e calcula total_pages corretamente' do
      get members_path, params: { pageSize: 2 }, headers: json_headers

      expect(response.parsed_body['data'].size).to eq(2)
      expect(response.parsed_body['pagination']['total_pages']).to eq(2)
    end

    it 'ordena por nome ascendente por padrão' do
      get members_path, headers: json_headers

      names = response.parsed_body['data'].map { |m| m['name'] }
      expect(names).to eq(names.sort)
    end

    it 'ordena por nome descendente com sort_order=desc' do
      get members_path, params: { sort_by: 'name', sort_order: 'desc' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      names = response.parsed_body['data'].map { |m| m['name'] }
      expect(names).to eq(names.sort.reverse)
    end

    it 'ordena por member_number ascendente' do
      get members_path, params: { sort_by: 'member_number', sort_order: 'asc' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      numbers = response.parsed_body['data'].map { |m| m['member_number'] }.compact
      expect(numbers).to eq(numbers.sort)
    end

    it 'ordena por member_number descendente' do
      get members_path, params: { sort_by: 'member_number', sort_order: 'desc' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      numbers = response.parsed_body['data'].map { |m| m['member_number'] }.compact
      expect(numbers).to eq(numbers.sort.reverse)
    end

    it 'filtra por nome parcial' do
      get members_path, params: { name: 'Ana' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end

    it 'filtra por document parcial' do
      get members_path, params: { document: '111' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end

    it 'retorna lista vazia quando nenhum membro bate com o filtro' do
      get members_path, params: { name: 'Inexistente' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_empty
      expect(response.parsed_body['pagination']['total_count']).to eq(0)
    end

    it 'combina filtro de name e document' do
      get members_path, params: { name: 'Ana', document: '111' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end

    context 'filtro active' do
      before { ana.soft_delete! }

      it 'active=true retorna apenas membros ativos' do
        get members_path, params: { active: 'true' }, headers: json_headers

        names = response.parsed_body['data'].map { |m| m['name'] }
        expect(names).to contain_exactly('Beto Souza', 'Carlos Neto')
      end

      it 'active=false retorna apenas membros inativos' do
        get members_path, params: { active: 'false' }, headers: json_headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
      end
    end

    it 'não retorna membros deletados' do
      ana.soft_delete!
      get members_path, headers: json_headers

      ids = response.parsed_body['data'].map { |m| m['id'].to_i }
      expect(ids).not_to include(ana.id)
    end
  end

  describe 'GET /members/:id' do
    let!(:membro) { create(:member, name: 'Dona Maria', document: '12300000001', member_number: 7) }

    it 'retorna o membro pelo id' do
      get member_path(membro), headers: json_headers

      expect(response).to have_http_status(:ok)
    end

    it 'retorna exatamente os campos id, name, document, member_number e voter' do
      get member_path(membro), headers: json_headers

      body = response.parsed_body
      expect(body.keys).to match_array(%w[id name document member_number voter])
      expect(body['id']).to eq(membro.id.to_s)
      expect(body['name']).to eq('Dona Maria')
      expect(body['document']).to eq('12300000001')
      expect(body['member_number']).to eq(7)
      expect(body['voter']).to eq(false)
    end

    it 'retorna 404 para id inexistente' do
      get member_path(id: 0), headers: json_headers

      expect(response).to have_http_status(:not_found)
    end

    it 'retorna 404 para membro soft-deleted' do
      membro.soft_delete!
      get member_path(membro), headers: json_headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /members/:id' do
    let!(:membro) { create(:member, name: 'Nome Original') }

    it 'atualiza o nome' do
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

    it 'retorna 422 ao atualizar com document duplicado' do
      outro = create(:member, document: '99988877766')

      patch member_path(membro), params: { member: { document: outro.document } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna código de erro E_2_1 ao usar document duplicado' do
      outro = create(:member, document: '99988877766')

      patch member_path(membro), params: { member: { document: outro.document } }, as: :json

      errors = response.parsed_body['errors']
      expect(errors).to be_an(Array)
      expect(errors.first['code']).to eq('E_2_1')
      expect(errors.first['field']).to eq('document')
    end

    it 'retorna 404 para id inexistente' do
      patch member_path(id: 0), params: { member: { name: 'X' } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /members/:id' do
    let!(:membro) { create(:member) }

    it 'retorna 204' do
      delete member_path(membro), as: :json

      expect(response).to have_http_status(:no_content)
    end

    it 'seta deleted_at (soft delete)' do
      delete member_path(membro), as: :json

      expect(membro.reload.deleted_at).not_to be_nil
    end

    it 'não aparece mais no index após deletar' do
      delete member_path(membro), as: :json
      get members_path, headers: json_headers

      ids = response.parsed_body['data'].map { |m| m['id'].to_i }
      expect(ids).not_to include(membro.id)
    end

    it 'retorna 404 para id inexistente' do
      delete member_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
