require 'rails_helper'

RSpec.describe 'GET /caixa', type: :request do
  let!(:paid_feb_cash) do
    create(:invoice, paid_at: Time.zone.local(2026, 2, 10, 9), payment_method: 'DINHEIRO',
                     amount_partner: 30.0, amount_water: nil)
  end
  let!(:paid_feb_pix) do
    create(:invoice, paid_at: Time.zone.local(2026, 2, 20, 9), payment_method: 'PIX',
                     amount_partner: 100.0, amount_water: 18.80)
  end
  let!(:paid_jan_cash) do
    create(:invoice, paid_at: Time.zone.local(2026, 1, 15, 9), payment_method: 'DINHEIRO',
                     amount_partner: 50.0, amount_water: nil)
  end
  let!(:unpaid) { create(:invoice, paid_at: nil) }

  it 'lists only paid invoices with total count and summed value' do
    get '/caixa'

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body['data'].map { |p| p['id'] })
      .to match_array([paid_feb_cash, paid_feb_pix, paid_jan_cash].map { |i| i.id.to_s })
    expect(body['total']).to eq(3)
    # amount_water nulo conta como 0 (COALESCE), não anula a linha.
    expect(body['total_value']).to be_within(0.01).of(198.80)
  end

  it 'filters by payment date range (startDate/endDate)' do
    get '/caixa', params: { startDate: '2026-02-01', endDate: '2026-02-28' }

    body = response.parsed_body
    expect(body['data'].map { |p| p['id'] })
      .to match_array([paid_feb_cash.id.to_s, paid_feb_pix.id.to_s])
    expect(body['total']).to eq(2)
    expect(body['total_value']).to be_within(0.01).of(148.80)
  end

  it 'filters by paymentMethod' do
    get '/caixa', params: { paymentMethod: 'PIX' }

    body = response.parsed_body
    expect(body['data'].map { |p| p['id'] }).to eq([paid_feb_pix.id.to_s])
    expect(body['total']).to eq(1)
  end

  it 'excludes soft-deleted invoices' do
    paid_feb_cash.soft_delete!

    get '/caixa'

    ids = response.parsed_body['data'].map { |p| p['id'] }
    expect(ids).not_to include(paid_feb_cash.id.to_s)
    expect(response.parsed_body['total']).to eq(2)
  end

  it 'returns the expected posting fields (snake_case)' do
    get '/caixa', params: { startDate: '2026-02-01', endDate: '2026-02-15' }

    posting = response.parsed_body['data'].first
    expect(posting).to include('id', 'member_name', 'number', 'payment_date', 'payment_method', 'value')
    expect(posting['payment_date']).to eq('2026-02-10')
    expect(posting['payment_method']).to eq('DINHEIRO')
    expect(posting['value']).to be_within(0.01).of(30.0)
    expect(posting['number']).to eq(paid_feb_cash.connection.number)
  end

  it 'paginates with page/pageSize while keeping totals over the full set' do
    get '/caixa', params: { page: 1, pageSize: 2 }

    body = response.parsed_body
    expect(body['data'].size).to eq(2)
    expect(body['total']).to eq(3)
    expect(body['page']).to eq(1)
    expect(body['pageSize']).to eq(2)
  end
end
