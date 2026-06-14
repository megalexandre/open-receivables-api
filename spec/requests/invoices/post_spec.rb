require 'rails_helper'

RSpec.describe 'POST /invoices', type: :request do
  let!(:connection) { create(:connection) }

  it 'creates invoice and returns 201' do
    expect {
      post '/invoices', params: {
        invoice: {
          connection_id: connection.id,
          due_date: 10.days.from_now.to_date,
          reference_date: Date.current.beginning_of_month,
          amount_partner: 100.50
        }
      }, as: :json
    }.to change(Invoice, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body['id']).to be_present
    expect(response.parsed_body['connectionId']).to eq(connection.id)
  end

  it 'returns validation errors for missing connection_id' do
    post '/invoices', params: {
      invoice: {
        due_date: 10.days.from_now.to_date
      }
    }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['errors']).to be_an(Array)
    expect(response.parsed_body['errors'].map { |e| e['code'] }).to include('E_INVOICE_REQUIRED')
  end

  it 'returns validation errors for missing due_date' do
    post '/invoices', params: {
      invoice: {
        connection_id: connection.id
      }
    }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['errors']).to be_an(Array)
  end
end
