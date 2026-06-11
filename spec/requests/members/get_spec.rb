require 'rails_helper'

RSpec.describe 'GET /members', type: :request do
  context 'status' do
    it 'retorna 200' do
      get members_path, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  context 'serialização' do
    it 'retorna os membros com todos os campos' do
      membro = create(:member, name: 'Ana Lima', document: '11100000001', member_number: 3).reload

      get members_path, as: :json

      expect(response.parsed_body['data']).to eq([
        {
          'id'            => membro.id,
          'name'          => 'Ana Lima',
          'document'      => '11100000001',
          'member_number' => 3,
          'voter'         => false,
          'active'        => true
        }
      ])
    end
  end

  context 'ordenação' do
    before do
      create(:member, name: 'Beto Souza',  member_number: 1)
      create(:member, name: 'Ana Lima',    member_number: 3)
      create(:member, name: 'Carlos Neto', member_number: 2)
    end

    it 'ordena por nome ascendente por padrão' do
      get members_path, as: :json

      names = response.parsed_body['data'].map { |m| m['name'] }
      expect(names).to eq(['Ana Lima', 'Beto Souza', 'Carlos Neto'])
    end

    it 'ordena por nome descendente com sort_order=desc' do
      get members_path, params: { sort_by: 'name', sort_order: 'desc' }

      names = response.parsed_body['data'].map { |m| m['name'] }
      expect(names).to eq(['Carlos Neto', 'Beto Souza', 'Ana Lima'])
    end

    it 'ordena por member_number ascendente' do
      get members_path, params: { sort_by: 'member_number', sort_order: 'asc' }

      numbers = response.parsed_body['data'].map { |m| m['member_number'] }
      expect(numbers).to eq([1, 2, 3])
    end

    it 'ordena por member_number descendente' do
      get members_path, params: { sort_by: 'member_number', sort_order: 'desc' }

      numbers = response.parsed_body['data'].map { |m| m['member_number'] }
      expect(numbers).to eq([3, 2, 1])
    end
  end

  context 'filtros' do
    let!(:ana)  { create(:member, name: 'Ana Lima',   document: '11100000001') }
    let!(:beto) { create(:member, name: 'Beto Souza', document: '22200000002') }

    it 'filtra por nome parcial' do
      get members_path, params: { name: 'Ana' }

      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end

    it 'filtra por document parcial' do
      get members_path, params: { document: '111' }

      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end

    it 'combina filtro de name e document' do
      get members_path, params: { name: 'Ana', document: '111' }

      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end

    it 'retorna lista vazia quando nenhum membro bate com o filtro' do
      get members_path, params: { name: 'Inexistente' }

      expect(response.parsed_body['data']).to be_empty
      expect(response.parsed_body['pagination']['total_count']).to eq(0)
    end

    it 'não retorna membros deletados' do
      ana.soft_delete!

      get members_path, as: :json

      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Beto Souza')
    end

    it 'active=true retorna apenas membros ativos' do
      ana.soft_delete!

      get members_path, params: { active: 'true' }

      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Beto Souza')
    end

    it 'active=false retorna apenas membros inativos' do
      ana.soft_delete!

      get members_path, params: { active: 'false' }

      expect(response.parsed_body['data'].map { |m| m['name'] }).to contain_exactly('Ana Lima')
    end
  end

  context 'paginação' do
    it 'retorna os metadados de paginação' do
      create_list(:member, 2)

      get members_path, as: :json

      expect(response.parsed_body['pagination']).to eq(
        'current_page' => 1,
        'total_pages'  => 1,
        'total_count'  => 2,
        'per_page'     => 20,
        'total'        => 2
      )
    end

    it 'respeita o pageSize informado e calcula total_pages corretamente' do
      create_list(:member, 3)

      get members_path, params: { pageSize: 2 }

      expect(response.parsed_body['data'].size).to eq(2)
      expect(response.parsed_body['pagination']['total_pages']).to eq(2)
    end
  end
end
