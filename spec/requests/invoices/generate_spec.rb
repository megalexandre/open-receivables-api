require 'rails_helper'

RSpec.describe 'POST /invoices/generate', type: :request do
  let!(:category) { create(:category, amount_partner: 100.0, amount_water: 50.0) }
  let!(:conn1)    { create(:connection, category:) }
  let!(:conn2)    { create(:connection, category:) }

  let(:due_date)       { 15.days.from_now.to_date.to_s }
  let(:reference_date) { Date.current.beginning_of_month.to_s }

  def generate(candidate_ids:, due_date: self.due_date, reference_date: self.reference_date)
    post '/invoices/generate', params: {
      candidate_ids: candidate_ids,
      due_date: due_date,
      reference_date: reference_date
    }, as: :json
  end

  it 'creates one invoice per candidate and returns 201' do
    expect {
      generate(candidate_ids: [conn1.id, conn2.id])
    }.to change(Invoice, :count).by(2)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body['created']).to eq(2)
  end

  it 'sets amounts from the connection category' do
    generate(candidate_ids: [conn1.id])

    invoice = Invoice.last
    expect(invoice.amount_partner).to eq(100.0)
    expect(invoice.amount_water).to eq(50.0)
  end

  it 'sets the correct due_date and reference_date' do
    generate(candidate_ids: [conn1.id], due_date: '2026-07-15', reference_date: '2026-07-01')

    invoice = Invoice.last
    expect(invoice.due_date.to_s).to eq('2026-07-15')
    expect(invoice.reference_date.to_s).to eq('2026-07-01')
  end

  it 'creates no invoices when candidate_ids is empty' do
    expect {
      generate(candidate_ids: [])
    }.not_to change(Invoice, :count)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body['created']).to eq(0)
  end

  it 'ignores non-existent connection ids without error' do
    expect {
      generate(candidate_ids: [conn1.id, 999_999])
    }.to change(Invoice, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body['created']).to eq(1)
  end
end
