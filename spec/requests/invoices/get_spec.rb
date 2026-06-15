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
      'id', 'connectionId', 'memberName', 'address', 'dueDate', 'referenceDate',
      'paidAt', 'amountPartner', 'amountWater', 'active', 'createdAt'
    )
  end

  it 'serializes decimal amounts as numbers (not strings)' do
    get "/invoices/#{invoice.id}", as: :json
    expect(response.parsed_body['amountPartner']).to be_a(Numeric)
  end

  it 'includes member name and address (type name number) from the connection' do
    address = create(:address, address_type: 'Avenida', name: 'Fernando Daltro')
    member = create(:member, name: 'Maria Souza')
    conn = create(:connection, address:, member:, number: '123')
    inv = create(:invoice, connection: conn)

    get "/invoices/#{inv.id}", as: :json

    expect(response.parsed_body['memberName']).to eq('Maria Souza')
    expect(response.parsed_body['address']).to eq('Avenida Fernando Daltro 123')
  end

  it 'returns 404 for non-existent invoice' do
    get '/invoices/99999', as: :json
    expect(response).to have_http_status(:not_found)
  end
end
