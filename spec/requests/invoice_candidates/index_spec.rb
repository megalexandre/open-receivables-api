require 'rails_helper'

RSpec.describe 'GET /invoice-candidates', type: :request do
  let!(:category_flat)  { create(:category, has_hydrometer: false, amount_partner: 100.0, amount_water: 50.0) }
  let!(:category_hydro) { create(:category, has_hydrometer: true,  amount_partner: 100.0, amount_water: 80.0) }
  let!(:address1)       { create(:address) }
  let!(:address2)       { create(:address) }

  let!(:conn_flat)  { create(:connection, category: category_flat,  address: address1) }
  let!(:conn_hydro) { create(:connection, category: category_hydro, address: address1) }
  let!(:conn_addr2) { create(:connection, category: category_flat,  address: address2) }

  let(:current_period) { Date.current.strftime('%m/%Y') }
  let(:current_month)  { Date.current.month }
  let(:current_year)   { Date.current.year }

  context 'without filters' do
    it 'returns all active connections without invoice for the period' do
      get '/invoice-candidates', params: { period: current_period }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].size).to eq(3)
      expect(response.parsed_body['total']).to eq(3)
    end

    it 'returns total_value as sum of all candidates' do
      get '/invoice-candidates', params: { period: current_period }

      expect(response.parsed_body['total_value']).to be_a(Numeric)
      expect(response.parsed_body['total_value']).to be > 0
    end

    it 'returns expected fields for each candidate' do
      get '/invoice-candidates', params: { period: current_period }

      candidate = response.parsed_body['data'].first
      expect(candidate).to include('id', 'member_name', 'address', 'category', 'valor_total', 'hdr_inicial')
    end

    it 'returns address as "type name number" (number from the connection)' do
      address = create(:address, address_type: 'Avenida', name: 'Fernando Daltro')
      connection = create(:connection, address: address, number: '123')

      get '/invoice-candidates', params: { period: current_period }

      candidate = response.parsed_body['data'].find { |c| c['id'].to_i == connection.id }
      expect(candidate['address']).to eq('Avenida Fernando Daltro 123')
    end
  end

  context 'when a connection already has an invoice for the period' do
    before do
      create(:invoice,
             connection: conn_flat,
             reference_date: Date.new(current_year, current_month, 1))
    end

    it 'excludes that connection from the candidates' do
      get '/invoice-candidates', params: { period: current_period }

      ids = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids).not_to include(conn_flat.id)
      expect(ids).to include(conn_hydro.id, conn_addr2.id)
    end
  end

  context 'after an invoice is generated for the period (POST /invoices/generate)' do
    it 'no longer lists that connection as a candidate for the same month' do
      get '/invoice-candidates', params: { period: current_period }
      ids_before = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids_before).to include(conn_flat.id)

      post '/invoices/generate', params: {
        candidate_ids: [conn_flat.id],
        due_date: Date.current.strftime('%Y-%m-%d'),
        reference_date: Date.new(current_year, current_month, 1).strftime('%Y-%m-%d')
      }
      expect(response).to have_http_status(:created)

      get '/invoice-candidates', params: { period: current_period }
      ids_after = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids_after).not_to include(conn_flat.id)
      expect(ids_after).to include(conn_hydro.id, conn_addr2.id)
    end
  end

  context 'when a connection has an invoice in a different period' do
    before do
      create(:invoice,
             connection: conn_flat,
             reference_date: Date.new(current_year, current_month, 1) - 1.month)
    end

    it 'still includes the connection as a candidate' do
      get '/invoice-candidates', params: { period: current_period }

      ids = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids).to include(conn_flat.id)
    end
  end

  context 'with meterType filter' do
    it 'returns only connections with hydrometer when meterType=com_hidrometro' do
      get '/invoice-candidates', params: { period: current_period, meterType: 'com_hidrometro' }

      ids = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids).to eq([conn_hydro.id])
    end

    it 'returns only connections without hydrometer when meterType=sem_hidrometro' do
      get '/invoice-candidates', params: { period: current_period, meterType: 'sem_hidrometro' }

      ids = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids).to contain_exactly(conn_flat.id, conn_addr2.id)
    end

    it 'returns all connections when meterType=all' do
      get '/invoice-candidates', params: { period: current_period, meterType: 'all' }

      expect(response.parsed_body['data'].size).to eq(3)
    end
  end

  context 'with addressId filter' do
    it 'returns only connections for the given address' do
      get '/invoice-candidates', params: { period: current_period, addressId: address1.id }

      ids = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids).to contain_exactly(conn_flat.id, conn_hydro.id)
    end
  end

  context 'when connection is deleted' do
    before { conn_flat.soft_delete! }

    it 'does not include deleted connections' do
      get '/invoice-candidates', params: { period: current_period }

      ids = response.parsed_body['data'].map { |c| c['id'].to_i }
      expect(ids).not_to include(conn_flat.id)
    end
  end

  context 'valor_total calculation' do
    it 'returns amount_partner + amount_water from category' do
      get '/invoice-candidates', params: { period: current_period }

      candidate = response.parsed_body['data'].find { |c| c['id'].to_i == conn_flat.id }
      expect(candidate['valor_total']).to eq(150.0)
    end
  end
end
