require 'rails_helper'

RSpec.describe 'WaterQuality', type: :request do
  let(:entry) { { parameter: 'Turbidez', required: 5.0, analyzed: 1.2, conformity: 5.0 } }

  describe 'POST /water-quality' do
    it 'cria as análises e retorna 201' do
      post '/water-quality', params: { month: 6, year: 2026, entries: [entry] }, as: :json

      expect(response).to have_http_status(:created)
      expect(WaterAnalysis.count).to eq(1)
    end

    it 'rejeita parâmetro duplicado na mesma referência com code E_WATER_ANALYSIS_DUPLICATED' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 6, 1))

      post '/water-quality', params: { month: 6, year: 2026, entries: [entry] }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      error = response.parsed_body['errors'].find { |e| e['code'] == 'E_WATER_ANALYSIS_DUPLICATED' }
      expect(error).to be_present
      expect(error['field']).to eq('parameter')
      expect(WaterAnalysis.count).to eq(1)
    end

    it 'rejeita parâmetro repetido no mesmo envio e desfaz a transação' do
      post '/water-quality', params: { month: 6, year: 2026, entries: [entry, entry] }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors'].first['code']).to eq('E_WATER_ANALYSIS_DUPLICATED')
      expect(WaterAnalysis.count).to eq(0)
    end

    it 'permite o mesmo parâmetro em referência diferente' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 5, 1))

      post '/water-quality', params: { month: 6, year: 2026, entries: [entry] }, as: :json

      expect(response).to have_http_status(:created)
      expect(WaterAnalysis.count).to eq(2)
    end
  end

  describe 'GET /water-quality' do
    it 'filtra pela competência informada (MM/YYYY)' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 6, 1))
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 5, 1))

      get '/water-quality', params: { reference: '06/2026' }

      expect(response).to have_http_status(:ok)
      references = response.parsed_body['data'].map { |a| a['reference'] }
      expect(references).to eq(['06/2026'])
    end

    it 'ordena conforme sort_by/sort_order' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 6, 1))
      create(:water_analysis, parameter: 'Cloro Residual', reference_date: Date.new(2026, 6, 1))

      get '/water-quality', params: { sort_by: 'parameter', sort_order: 'asc' }

      parameters = response.parsed_body['data'].map { |a| a['parameter'] }
      expect(parameters).to eq(['Cloro Residual', 'Turbidez'])
    end
  end

  describe 'DELETE /water-quality' do
    it 'remove apenas as análises da competência informada' do
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 6, 1))
      create(:water_analysis, parameter: 'Cloro Residual', reference_date: Date.new(2026, 6, 1))
      create(:water_analysis, parameter: 'Turbidez', reference_date: Date.new(2026, 5, 1))

      delete '/water-quality', params: { reference: '06/2026' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['deleted']).to eq(2)
      expect(WaterAnalysis.pluck(:reference_date).map { |d| d.strftime('%m/%Y') }).to eq(['05/2026'])
    end
  end
end
