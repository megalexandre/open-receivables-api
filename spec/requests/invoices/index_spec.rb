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
end
