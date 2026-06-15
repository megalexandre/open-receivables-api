require 'rails_helper'

RSpec.describe 'GET /invoices', type: :request do
  let!(:connection1) { create(:connection) }
  let!(:connection2) { create(:connection) }
  let!(:invoice1) { create(:invoice, connection: connection1) }
  let!(:invoice2) { create(:invoice, connection: connection2) }

  it 'returns list of invoices' do
    get '/invoices', as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['data']).to be_an(Array)
    expect(response.parsed_body['data'].size).to eq(2)
  end

  it 'returns pagination metadata' do
    get '/invoices', as: :json
    expect(response.parsed_body['pagination']).to include('current_page', 'per_page', 'total_count')
  end

  describe 'sorting (sortBy/sortOrder)' do
    let!(:conn) { create(:connection) }

    before do
      create(:invoice, connection: conn, due_date: Date.new(2026, 1, 10), reference_date: Date.new(2026, 1, 1))
      create(:invoice, connection: conn, due_date: Date.new(2026, 3, 10), reference_date: Date.new(2026, 3, 1))
      create(:invoice, connection: conn, due_date: Date.new(2026, 2, 10), reference_date: Date.new(2026, 2, 1))
    end

    it 'orders ascending with sortBy=due_date&sortOrder=asc' do
      get '/invoices', params: { sortBy: 'due_date', sortOrder: 'asc' }

      dates = response.parsed_body['data'].map { |i| i['dueDate'] }
      expect(dates).to eq(dates.sort)
    end

    it 'orders descending with sortBy=due_date&sortOrder=desc' do
      get '/invoices', params: { sortBy: 'due_date', sortOrder: 'desc' }

      dates = response.parsed_body['data'].map { |i| i['dueDate'] }
      expect(dates).to eq(dates.sort.reverse)
    end
  end

  describe 'filtering' do
    let!(:member_a)  { create(:member, name: 'Ana') }
    let!(:address_a) { create(:address, address_type: 'Rua', name: 'Alfa') }
    let!(:conn_a)    { create(:connection, member: member_a, address: address_a) }
    let!(:inv_a) do
      create(:invoice, connection: conn_a,
                       due_date: Date.new(2026, 5, 10),
                       reference_date: Date.new(2026, 5, 1),
                       paid_at: nil)
    end

    let!(:conn_b) { create(:connection) }
    let!(:inv_b) do
      create(:invoice, connection: conn_b,
                       due_date: Date.new(2026, 6, 10),
                       reference_date: Date.new(2026, 6, 1),
                       paid_at: Time.current)
    end

    def ids = response.parsed_body['data'].map { |i| i['id'] }

    it 'filters by number (invoice id)' do
      get '/invoices', params: { number: inv_a.id }
      expect(ids).to eq([inv_a.id])
    end

    it 'filters by member_id' do
      get '/invoices', params: { member_id: member_a.id }
      expect(ids).to contain_exactly(inv_a.id)
    end

    it 'filters by address_id' do
      get '/invoices', params: { address_id: address_a.id }
      expect(ids).to contain_exactly(inv_a.id)
    end

    it 'filters by competencia (MM/yyyy)' do
      get '/invoices', params: { competencia: '05/2026' }
      expect(ids).to contain_exactly(inv_a.id)
    end

    it 'filters by due_date' do
      get '/invoices', params: { due_date: '2026-06-10' }
      expect(ids).to contain_exactly(inv_b.id)
    end

    it 'filters by paid' do
      get '/invoices', params: { paid: 'true' }
      expect(ids).to contain_exactly(inv_b.id)
    end
  end
end
