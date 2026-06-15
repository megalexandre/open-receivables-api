require 'rails_helper'

RSpec.describe 'Invoice payment (baixa)', type: :request do
  let!(:connection) { create(:connection) }

  describe 'PATCH /invoices/:id/pay' do
    let!(:invoice) { create(:invoice, connection:, paid_at: nil) }

    it 'marks the invoice as paid at the given date and payment method' do
      patch "/invoices/#{invoice.id}/pay", params: { paid_at: '2026-06-10', payment_method: 'PIX' }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['paidAt']).to be_present
      expect(invoice.reload.paid_at.to_date).to eq(Date.new(2026, 6, 10))
      expect(invoice.payment_method).to eq('PIX')
    end

    it 'defaults to now and DINHEIRO when not given' do
      patch "/invoices/#{invoice.id}/pay", as: :json

      expect(response).to have_http_status(:ok)
      expect(invoice.reload.paid_at).to be_present
      expect(invoice.payment_method).to eq('DINHEIRO')
    end
  end

  describe 'PATCH /invoices/:id/unpay' do
    let!(:invoice) { create(:invoice, connection:, paid_at: Time.current, payment_method: 'PIX') }

    it 'reverts the invoice to pending and clears the payment method' do
      patch "/invoices/#{invoice.id}/unpay", as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['paidAt']).to be_nil
      expect(invoice.reload.paid_at).to be_nil
      expect(invoice.payment_method).to be_nil
    end
  end
end
