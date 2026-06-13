require 'rails_helper'

RSpec.describe 'GET /connections com filtro de inativos', type: :request do
  let(:address1) { create(:address, name: 'Rua A') }
  let(:address2) { create(:address, name: 'Rua B') }
  let(:member1) { create(:member, name: 'João') }
  let(:member2) { create(:member, name: 'Maria') }
  let(:category) { create(:category) }

  describe 'filtro active=false (inativos)' do
    let!(:active_joao_addr1) do
      create(:connection, address: address1, member: member1, category: category)
    end
    let!(:active_maria_addr2) do
      create(:connection, address: address2, member: member2, category: category)
    end
    let!(:inactive_joao_addr1) do
      conn = create(:connection, address: address1, member: member1, category: category)
      conn.soft_delete!
      conn
    end
    let!(:inactive_joao_addr2) do
      conn = create(:connection, address: address2, member: member1, category: category)
      conn.soft_delete!
      conn
    end
    let!(:inactive_maria_addr1) do
      conn = create(:connection, address: address1, member: member2, category: category)
      conn.soft_delete!
      conn
    end

    it 'retorna todas as conexões inativas sem filtro de membro' do
      get "#{connections_path}?active=false", as: :json

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.length).to eq(3)
      inactive_ids = [inactive_joao_addr1.id, inactive_joao_addr2.id, inactive_maria_addr1.id]
      expect(data.map { |c| c['id'] }.sort).to eq(inactive_ids.sort)
    end

    context 'filtrando por memberId específico' do
      it 'retorna apenas as inativas de João' do
        get "#{connections_path}?active=false&memberId=#{member1.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(2)
        joao_inactive_ids = [inactive_joao_addr1.id, inactive_joao_addr2.id]
        expect(data.map { |c| c['id'] }.sort).to eq(joao_inactive_ids.sort)
        expect(data.all? { |c| c['memberName'] == 'João' }).to be true
      end

      it 'retorna apenas a inativa de Maria' do
        get "#{connections_path}?active=false&memberId=#{member2.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(1)
        expect(data.first['id']).to eq(inactive_maria_addr1.id)
        expect(data.first['memberName']).to eq('Maria')
      end

      it 'retorna vazio quando membro não tem inativas' do
        other_member = create(:member, name: 'Pedro')
        get "#{connections_path}?active=false&memberId=#{other_member.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data).to be_empty
      end
    end

    context 'filtrando por addressId' do
      it 'retorna inativas do endereço 1' do
        get "#{connections_path}?active=false&addressId=#{address1.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(2)
        addr1_inactive_ids = [inactive_joao_addr1.id, inactive_maria_addr1.id]
        expect(data.map { |c| c['id'] }.sort).to eq(addr1_inactive_ids.sort)
      end

      it 'retorna inativas do endereço 2' do
        get "#{connections_path}?active=false&addressId=#{address2.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(1)
        expect(data.first['id']).to eq(inactive_joao_addr2.id)
      end
    end

    context 'filtros combinados: active=false + memberId + addressId' do
      it 'retorna inativa de João no endereço 1' do
        get "#{connections_path}?active=false&memberId=#{member1.id}&addressId=#{address1.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(1)
        expect(data.first['id']).to eq(inactive_joao_addr1.id)
        expect(data.first['memberName']).to eq('João')
        expect(data.first['address']).to include('Rua A')
      end

      it 'retorna inativa de João no endereço 2' do
        get "#{connections_path}?active=false&memberId=#{member1.id}&addressId=#{address2.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(1)
        expect(data.first['id']).to eq(inactive_joao_addr2.id)
      end

      it 'retorna vazio quando combinação não existe' do
        get "#{connections_path}?active=false&memberId=#{member2.id}&addressId=#{address2.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data).to be_empty
      end

      it 'retorna inativa de Maria no endereço 1' do
        get "#{connections_path}?active=false&memberId=#{member2.id}&addressId=#{address1.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.length).to eq(1)
        expect(data.first['id']).to eq(inactive_maria_addr1.id)
        expect(data.first['memberName']).to eq('Maria')
      end
    end

    context 'garantir que ativos não são retornados' do
      it 'filtra conexões ativas quando pede inativos com memberId' do
        # Criar mais ativas
        create(:connection, address: address1, member: member1, category: category)
        create(:connection, address: address2, member: member1, category: category)

        get "#{connections_path}?active=false&memberId=#{member1.id}", as: :json

        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        # Deve retornar apenas as 2 inativas, não as ativas
        expect(data.length).to eq(2)
        expect(data.all? { |c| c['active'] == false }).to be true
      end
    end
  end
end
