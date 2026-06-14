require 'rails_helper'

RSpec.describe 'GET /invoices/:id', type: :request do
  let!(:connection) { create(:connection) }
  let!(:invoice) { create(:invoice, connection:) }

  it 'returns invoice details' do
    get "/invoices/#{invoice.id}", as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['id']).to eq(invoice.id)
    expect(response.parsed_body['connectionId']).to eq(invoice.connection_id)
  end

  it 'returns serialized invoice with camelCase keys' do
    get "/invoices/#{invoice.id}", as: :json
    expect(response.parsed_body).to include(
      'id', 'connectionId', 'dueDate', 'referenceDate',
      'paidAt', 'amountPartner', 'amountWater', 'active', 'createdAt'
    )
  end

  it 'returns 404 for non-existent invoice' do
    get '/invoices/99999', as: :json
    expect(response).to have_http_status(:not_found)
  end
end
