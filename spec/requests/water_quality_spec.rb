require 'rails_helper'

RSpec.describe 'WaterQuality', type: :request do
  let(:entry) { { parameter: 'Turbidez', required: 5.0, analyzed: 1.2, conformity: 5.0 } }

  describe 'POST /water-quality' do
    it 'cria as análises e retorna 201' do
      post '/water-quality', params: { month: 6, year: 2026, entries: [entry] }, as: :json

      expect(response).to have_http_status(:created)
      expect(WaterAnalysis.count).to eq(1)
    end

    it 'rejeita parâmetro duplicado na mesma referência' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 6, 1))

      post '/water-quality', params: { month: 6, year: 2026, entries: [entry] }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['error']).to include('já existe uma análise')
      expect(WaterAnalysis.count).to eq(1)
    end

    it 'rejeita parâmetro repetido no mesmo envio e desfaz a transação' do
      post '/water-quality', params: { month: 6, year: 2026, entries: [entry, entry] }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(WaterAnalysis.count).to eq(0)
    end

    it 'permite o mesmo parâmetro em referência diferente' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 5, 1))

      post '/water-quality', params: { month: 6, year: 2026, entries: [entry] }, as: :json

      expect(response).to have_http_status(:created)
      expect(WaterAnalysis.count).to eq(2)
    end
  end
end
