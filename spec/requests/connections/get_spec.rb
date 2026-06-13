require 'rails_helper'

RSpec.describe 'GET /connections', type: :request do
  let(:address1) { create(:address, name: 'Rua A') }
  let(:address2) { create(:address, name: 'Rua B') }
  let(:member1)  { create(:member, name: 'João') }
  let(:member2)  { create(:member, name: 'Maria') }
  let(:category) { create(:category) }

  describe 'paginação' do
    before do
      create_list(:connection, 30,
        address: address1,
        member: member1,
        category: category
      )
    end

    it 'retorna primeira página com 25 conexões' do
      get "#{connections_path}?page=1&pageSize=25", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(25)
      expect(response.parsed_body['pagination']['total_count']).to eq(30)
      expect(response.parsed_body['pagination']['current_page']).to eq(1)
    end

    it 'retorna segunda página com 5 conexões' do
      get "#{connections_path}?page=2&pageSize=25", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(5)
      expect(response.parsed_body['pagination']['current_page']).to eq(2)
    end
  end

  describe 'filtro por status active' do
    let!(:active_conn1) do
      create(:connection, address: address1, member: member1, category: category)
    end
    let!(:active_conn2) do
      create(:connection, address: address2, member: member2, category: category)
    end
    let!(:inactive_conn) do
      conn = create(:connection, address: address1, member: member2, category: category)
      conn.soft_delete!
      conn
    end

    it 'sem parâmetro retorna apenas conexões ativas' do
      get connections_path, as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(2)
      expect(data.map { |c| c['id'] }.sort).to eq([active_conn1.id, active_conn2.id].sort)
    end

    it 'com active=true retorna apenas conexões ativas' do
      get "#{connections_path}?active=true", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(2)
      expect(data.map { |c| c['id'] }.sort).to eq([active_conn1.id, active_conn2.id].sort)
    end

    it 'com active=false retorna apenas conexões inativas' do
      get "#{connections_path}?active=false", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(1)
      expect(data.first['id']).to eq(inactive_conn.id)
    end
  end

  describe 'filtro por memberId' do
    let!(:joao_conn1) do
      create(:connection, address: address1, member: member1, category: category)
    end
    let!(:joao_conn2) do
      create(:connection, address: address2, member: member1, category: category)
    end
    let!(:maria_conn) do
      create(:connection, address: address1, member: member2, category: category)
    end

    it 'retorna conexões filtrando por ID do sócio' do
      get "#{connections_path}?memberId=#{member1.id}", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(2)
      expect(data.map { |c| c['id'] }.sort).to eq([joao_conn1.id, joao_conn2.id].sort)
    end

    it 'retorna vazio quando nenhuma conexão para esse membro' do
      other_member = create(:member, name: 'Outro Sócio')
      get "#{connections_path}?memberId=#{other_member.id}", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data).to be_empty
    end
  end

  describe 'filtro por addressId' do
    let!(:addr1_conn1) do
      create(:connection, address: address1, member: member1, category: category)
    end
    let!(:addr1_conn2) do
      create(:connection, address: address1, member: member2, category: category)
    end
    let!(:addr2_conn) do
      create(:connection, address: address2, member: member1, category: category)
    end

    it 'retorna conexões filtrando por endereço' do
      get "#{connections_path}?addressId=#{address1.id}", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(2)
      expect(data.map { |c| c['id'] }.sort).to eq([addr1_conn1.id, addr1_conn2.id].sort)
    end

    it 'retorna vazio quando endereço não tem conexões' do
      empty_address = create(:address, name: 'Rua Vazia')
      get "#{connections_path}?addressId=#{empty_address.id}", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data).to be_empty
    end
  end

  describe 'filtros combinados' do
    let!(:active_addr1_joao) do
      create(:connection, address: address1, member: member1, category: category)
    end
    let!(:active_addr2_joao) do
      create(:connection, address: address2, member: member1, category: category)
    end
    let!(:active_addr1_maria) do
      create(:connection, address: address1, member: member2, category: category)
    end
    let!(:inactive_addr1_joao) do
      conn = create(:connection, address: address1, member: member1, category: category)
      conn.soft_delete!
      conn
    end

    it 'filtra por active=true e memberId' do
      get "#{connections_path}?active=true&memberId=#{member1.id}", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(2)
      expect(data.map { |c| c['id'] }.sort).to eq([active_addr1_joao.id, active_addr2_joao.id].sort)
    end

    it 'filtra por active=true, memberId e addressId' do
      get "#{connections_path}?active=true&memberId=#{member1.id}&addressId=#{address1.id}", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(1)
      expect(data.first['id']).to eq(active_addr1_joao.id)
    end

    it 'filtra por active=false' do
      get "#{connections_path}?active=false", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(1)
      expect(data.first['id']).to eq(inactive_addr1_joao.id)
    end
  end

  describe 'ordenação' do
    let!(:conn_joao) do
      create(:connection, address: address1, member: member1, category: category)
    end
    let!(:conn_maria) do
      create(:connection, address: address2, member: member2, category: category)
    end

    it 'ordena por member_name ascendente (padrão)' do
      get connections_path, as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.first['memberName']).to eq('João')
      expect(data.last['memberName']).to eq('Maria')
    end

    it 'ordena por member_name descendente' do
      get "#{connections_path}?sort_by=member_name&sort_direction=desc", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.first['memberName']).to eq('Maria')
      expect(data.last['memberName']).to eq('João')
    end
  end

  describe 'resposta serializada' do
    let!(:connection) do
      create(:connection,
        address: address1,
        member: member1,
        category: category,
        number: '2024',
        registration_date: '2024-01-15'.to_date,
        partner_exclusive: true
      )
    end

    it 'retorna dados no formato esperado' do
      get connections_path, as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data).not_to be_empty
      conn = data.first

      expect(conn).to have_key('id')
      expect(conn).to have_key('memberName')
      expect(conn['memberName']).to eq('João')
      expect(conn).to have_key('address')
      expect(conn['address']).to include('Rua A')
      expect(conn).to have_key('categoryName')
      expect(conn).to have_key('value')
      expect(conn).to have_key('active')
      expect(conn['active']).to eq(true)
      expect(conn).to have_key('number')
      expect(conn['number']).to eq('2024')
      expect(conn).to have_key('registrationDate')
      expect(conn).to have_key('partnerExclusive')
      expect(conn['partnerExclusive']).to eq(true)
    end

    it 'retorna paginação com metadados' do
      get connections_path, as: :json

      expect(response).to have_http_status(:ok)
      pagination = response.parsed_body['pagination']
      expect(pagination).to have_key('total_count')
      expect(pagination).to have_key('current_page')
      expect(pagination).to have_key('per_page')
      expect(pagination['total_count']).to eq(1)
      expect(pagination['current_page']).to eq(1)
    end
  end
end
