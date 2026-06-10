require 'rails_helper'

RSpec.describe 'GET /addresses', type: :request do
  context 'status' do
    it 'retorna 200' do
      get addresses_path, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  context 'serialização' do
    it 'retorna os logradouros com todos os campos' do
      rua = create(:address, address_type: 'Rua', name: 'das Flores', notes: 'Próximo à praça').reload

      get addresses_path, as: :json

      expect(response.parsed_body['data']).to eq([
        {
          'id'           => rua.id,
          'address_type' => 'Rua',
          'name'         => 'das Flores',
          'notes'        => 'Próximo à praça'
        }
      ])
    end
  end

  context 'ordenação' do
    it 'ordena por address_type e name ascendentes por padrão' do
      create(:address, address_type: 'Rua',     name: 'das Flores')
      create(:address, address_type: 'Avenida', name: 'Brasil')
      create(:address, address_type: 'Avenida', name: 'Argentina')

      get addresses_path, as: :json

      names = response.parsed_body['data'].map { |a| "#{a['address_type']} #{a['name']}" }
      expect(names).to eq(['Avenida Argentina', 'Avenida Brasil', 'Rua das Flores'])
    end
  end

  context 'filtros' do
    it 'filtra por address_type' do
      create(:address, address_type: 'Rua',     name: 'das Flores')
      create(:address, address_type: 'Avenida', name: 'Brasil')

      get addresses_path, params: { address_type: 'Avenida' }

      expect(response.parsed_body['data'].map { |a| a['name'] }).to eq(['Brasil'])
    end

    it 'filtra por name parcial' do
      create(:address, address_type: 'Rua', name: 'das Flores')
      create(:address, address_type: 'Rua', name: 'Brasil')

      get addresses_path, params: { name: 'Flor' }

      expect(response.parsed_body['data'].map { |a| a['name'] }).to eq(['das Flores'])
    end
  end

  context 'paginação' do
    it 'retorna os metadados de paginação' do
      create_list(:address, 2)

      get addresses_path, as: :json

      expect(response.parsed_body['pagination']).to eq(
        'current_page' => 1,
        'total_pages'  => 1,
        'total_count'  => 2,
        'per_page'     => 20,
        'total'        => 2
      )
    end
  end
end
