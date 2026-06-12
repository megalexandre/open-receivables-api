require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  let(:json_headers) { { 'Accept' => 'application/json' } }
  let(:valid_params) do
    {
      category: {
        name:           'Categoria Teste',
        member_type:    'Sócio Efetivo',
        amount_water:   50.0,
        amount_partner: 30.0,
        has_hydrometer: true
      }
    }
  end

  describe 'POST /categories' do
    context 'com dados válidos' do
      it 'cria categoria e retorna 201' do
        post categories_path, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'retorna os campos esperados com valores corretos' do
        post categories_path, params: valid_params, as: :json

        body = response.parsed_body
        expect(body).to include(
          'name'           => 'Categoria Teste',
          'member_type'    => 'Sócio Efetivo',
          'amount_water'   => 50.0,
          'amount_partner' => 30.0,
          'has_hydrometer' => true
        )
        expect(body['id']).to be_present
      end

      it 'permite o mesmo nome em member_type diferente' do
        create(:category, name: 'Categoria Teste', member_type: 'Sócio Fundador')

        post categories_path, params: valid_params, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'aceita os três member_types válidos' do
        Category::MEMBER_TYPES.each_with_index do |type, idx|
          params = { category: valid_params[:category].merge(name: "Cat #{idx}", member_type: type) }
          post categories_path, params: params, as: :json

          expect(response).to have_http_status(:created)
        end
      end
    end

    context 'com dados inválidos' do
      it 'retorna 422 sem name' do
        params = { category: valid_params[:category].except(:name) }
        post categories_path, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'retorna errors com field name e código E_CATEGORY_REQUIRED ao omitir name' do
        params = { category: valid_params[:category].except(:name) }
        post categories_path, params: params, as: :json

        errors = response.parsed_body['errors']
        expect(errors).to be_an(Array)
        name_error = errors.find { |e| e['field'] == 'name' }
        expect(name_error).not_to be_nil
        expect(name_error['code']).to eq('E_CATEGORY_REQUIRED')
      end

      it 'retorna 422 sem member_type' do
        params = { category: valid_params[:category].except(:member_type) }
        post categories_path, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'retorna código E_CATEGORY_REQUIRED com field member_type ao omitir member_type' do
        params = { category: valid_params[:category].except(:member_type) }
        post categories_path, params: params, as: :json

        errors = response.parsed_body['errors']
        member_type_error = errors.find { |e| e['field'] == 'member_type' }
        expect(member_type_error).not_to be_nil
        expect(member_type_error['code']).to eq('E_CATEGORY_REQUIRED')
      end

      it 'retorna 422 com member_type inválido' do
        params = { category: valid_params[:category].merge(member_type: 'Tipo Inexistente') }
        post categories_path, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'retorna código E_CATEGORY_INVALID com field member_type para member_type inválido' do
        params = { category: valid_params[:category].merge(member_type: 'Tipo Inexistente') }
        post categories_path, params: params, as: :json

        errors = response.parsed_body['errors']
        member_type_error = errors.find { |e| e['field'] == 'member_type' }
        expect(member_type_error).not_to be_nil
        expect(member_type_error['code']).to eq('E_CATEGORY_INVALID')
      end
    end

    context 'com name duplicado no mesmo member_type' do
      let!(:existente) { create(:category, name: 'Duplicada', member_type: 'Sócio Efetivo') }

      it 'retorna 422' do
        params = { category: valid_params[:category].merge(name: 'Duplicada') }
        post categories_path, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'não cria um novo registro' do
        expect {
          params = { category: valid_params[:category].merge(name: 'Duplicada') }
          post categories_path, params: params, as: :json
        }.not_to change(Category, :count)
      end

      it 'retorna código de erro E_CATEGORY_DUPLICATED com field name' do
        params = { category: valid_params[:category].merge(name: 'Duplicada') }
        post categories_path, params: params, as: :json

        errors = response.parsed_body['errors']
        expect(errors).to be_an(Array)
        name_error = errors.find { |e| e['field'] == 'name' }
        expect(name_error).not_to be_nil
        expect(name_error['code']).to eq('E_CATEGORY_DUPLICATED')
      end
    end

    context 'com name duplicado de uma categoria inativa' do
      it 'retorna 422 (deve reativar em vez de recriar)' do
        create(:category, name: 'Inativa', member_type: 'Sócio Efetivo').soft_delete!

        params = { category: valid_params[:category].merge(name: 'Inativa') }
        expect {
          post categories_path, params: params, as: :json
        }.not_to change(Category.unscoped, :count)

        expect(response).to have_http_status(:unprocessable_content)

        error = response.parsed_body['errors'].find { |e| e['code'] == 'E_CATEGORY_DUPLICATED' }
        expect(error).to be_present
        expect(error['field']).to eq('name')
      end
    end
  end

  describe 'GET /categories' do
    let!(:cat_a) { create(:category, name: 'Categoria A', member_type: 'Sócio Efetivo',    amount_water: 50.0, amount_partner: 30.0) }
    let!(:cat_b) { create(:category, name: 'Categoria B', member_type: 'Sócio Fundador',   amount_water: 40.0, amount_partner: 20.0) }
    let!(:cat_c) { create(:category, name: 'Categoria C', member_type: 'Sócio Temporário', amount_water: 60.0, amount_partner: 10.0) }

    it 'retorna todas as categorias ativas' do
      get categories_path, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].map { |c| c['name'] })
        .to contain_exactly('Categoria A', 'Categoria B', 'Categoria C')
    end

    it 'cada item do array data contém os campos esperados' do
      get categories_path, headers: json_headers

      item = response.parsed_body['data'].first
      expect(item).to include('id', 'name', 'member_type', 'amount_water', 'amount_partner', 'has_hydrometer')
    end

    it 'amount_water e amount_partner são retornados como números' do
      get categories_path, headers: json_headers

      item = response.parsed_body['data'].find { |c| c['name'] == 'Categoria A' }
      expect(item['amount_water'].to_f).to eq(50.0)
      expect(item['amount_partner'].to_f).to eq(30.0)
    end

    it 'retorna estrutura de paginação no body' do
      get categories_path, headers: json_headers

      pagination = response.parsed_body['pagination']
      expect(pagination).to include('current_page', 'total_pages', 'total_count', 'per_page')
      expect(pagination['current_page']).to eq(1)
      expect(pagination['total_count']).to eq(3)
    end

    it 'respeita o pageSize informado' do
      get categories_path, params: { pageSize: 2 }, headers: json_headers

      expect(response.parsed_body['data'].size).to eq(2)
      expect(response.parsed_body['pagination']['total_pages']).to eq(2)
    end

    it 'ordena por nome ascendente por padrão' do
      get categories_path, headers: json_headers

      names = response.parsed_body['data'].map { |c| c['name'] }
      expect(names).to eq(names.sort)
    end

    it 'ordena por nome descendente com sort_order=desc' do
      get categories_path, params: { sort_by: 'name', sort_order: 'desc' }, headers: json_headers

      expect(response).to have_http_status(:ok)
      names = response.parsed_body['data'].map { |c| c['name'] }
      expect(names).to eq(names.sort.reverse)
    end

    it 'ordena por member_type ascendente' do
      get categories_path, params: { sort_by: 'member_type', sort_order: 'asc' }, headers: json_headers

      types = response.parsed_body['data'].map { |c| c['member_type'] }
      expect(types).to eq(types.sort)
    end

    it 'ordena por amount_water ascendente' do
      get categories_path, params: { sort_by: 'amount_water', sort_order: 'asc' }, headers: json_headers

      amounts = response.parsed_body['data'].map { |c| c['amount_water'].to_f }
      expect(amounts).to eq(amounts.sort)
    end

    it 'ordena por amount_partner ascendente' do
      get categories_path, params: { sort_by: 'amount_partner', sort_order: 'asc' }, headers: json_headers

      amounts = response.parsed_body['data'].map { |c| c['amount_partner'].to_f }
      expect(amounts).to eq(amounts.sort)
    end

    it 'ordena pelo total (amount_water + amount_partner) ascendente' do
      get categories_path, params: { sort_by: 'total', sort_order: 'asc' }, headers: json_headers

      totals = response.parsed_body['data'].map { |c| c['amount_water'].to_f + c['amount_partner'].to_f }
      expect(totals).to eq(totals.sort)
    end

    it 'não retorna categorias deletadas' do
      cat_a.soft_delete!
      get categories_path, headers: json_headers

      names = response.parsed_body['data'].map { |c| c['name'] }
      expect(names).not_to include('Categoria A')
    end

    it 'retorna active true para categorias ativas' do
      get categories_path, headers: json_headers

      expect(response.parsed_body['data']).to all(include('active' => true))
    end

    it 'active=false retorna apenas categorias inativas' do
      cat_a.soft_delete!

      get categories_path, params: { active: 'false' }, headers: json_headers

      names = response.parsed_body['data'].map { |c| c['name'] }
      expect(names).to contain_exactly('Categoria A')
      expect(response.parsed_body['data']).to all(include('active' => false))
    end
  end

  describe 'PATCH /categories/:id/reactivate' do
    context 'quando a categoria está deletada' do
      let!(:categoria) { create(:category, name: 'Categoria Antiga').tap(&:soft_delete!) }

      it 'reativa a categoria e retorna 200' do
        patch reactivate_category_path(categoria), as: :json

        expect(response).to have_http_status(:ok)
        expect(categoria.reload.deleted_at).to be_nil
        expect(categoria.deleted_by).to be_nil
      end

      it 'retorna a categoria com active true no body' do
        patch reactivate_category_path(categoria), as: :json

        body = response.parsed_body
        expect(body['id']).to eq(categoria.id)
        expect(body['active']).to eq(true)
      end

      it 'categoria volta a aparecer no index' do
        patch reactivate_category_path(categoria), as: :json
        get categories_path, headers: json_headers

        ids = response.parsed_body['data'].map { |c| c['id'] }
        expect(ids).to include(categoria.id)
      end
    end

    context 'quando a categoria está ativa' do
      let!(:categoria) { create(:category) }

      it 'retorna 200 e mantém a categoria ativa (idempotente)' do
        patch reactivate_category_path(categoria), as: :json

        expect(response).to have_http_status(:ok)
        expect(categoria.reload.deleted_at).to be_nil
      end
    end

    context 'quando a categoria não existe' do
      it 'retorna 404' do
        patch reactivate_category_path(id: 0), as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /categories/:id' do
    let!(:categoria) { create(:category, name: 'Res. Padrão', member_type: 'Sócio Efetivo', amount_water: 55.0, amount_partner: 25.0) }

    it 'retorna a categoria pelo id' do
      get category_path(categoria), headers: json_headers

      expect(response).to have_http_status(:ok)
    end

    it 'retorna os campos esperados com valores corretos' do
      get category_path(categoria), headers: json_headers

      body = response.parsed_body
      expect(body).to include(
        'name'        => 'Res. Padrão',
        'member_type' => 'Sócio Efetivo'
      )
      expect(body['id']).to be_present
      expect(body['amount_water'].to_f).to eq(55.0)
      expect(body['amount_partner'].to_f).to eq(25.0)
    end

    it 'retorna 404 para id inexistente' do
      get category_path(id: 0), headers: json_headers

      expect(response).to have_http_status(:not_found)
    end

    it 'retorna 404 para categoria soft-deleted' do
      categoria.soft_delete!
      get category_path(categoria), headers: json_headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /categories/:id' do
    let!(:categoria) { create(:category, name: 'Original', member_type: 'Sócio Efetivo') }

    it 'atualiza o nome e retorna 200' do
      patch category_path(categoria), params: { category: { name: 'Atualizado' } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(categoria.reload.name).to eq('Atualizado')
    end

    it 'retorna a categoria atualizada no body' do
      patch category_path(categoria), params: { category: { name: 'Atualizado' } }, as: :json

      expect(response.parsed_body).to include('name' => 'Atualizado')
    end

    it 'atualiza amount_water e amount_partner' do
      patch category_path(categoria), params: { category: { amount_water: 99.0, amount_partner: 49.0 } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(categoria.reload.amount_water).to eq(99.0)
      expect(categoria.reload.amount_partner).to eq(49.0)
    end

    it 'retorna 422 ao usar nome duplicado no mesmo member_type' do
      create(:category, name: 'Duplicado', member_type: categoria.member_type)

      patch category_path(categoria), params: { category: { name: 'Duplicado' } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'retorna código E_CATEGORY_DUPLICATED ao usar nome duplicado no mesmo member_type' do
      create(:category, name: 'Duplicado', member_type: categoria.member_type)

      patch category_path(categoria), params: { category: { name: 'Duplicado' } }, as: :json

      errors = response.parsed_body['errors']
      name_error = errors.find { |e| e['field'] == 'name' }
      expect(name_error).not_to be_nil
      expect(name_error['code']).to eq('E_CATEGORY_DUPLICATED')
    end

    it 'retorna 404 para id inexistente' do
      patch category_path(id: 0), params: { category: { name: 'X' } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /categories/:id' do
    let!(:categoria) { create(:category) }

    it 'retorna 204' do
      delete category_path(categoria), as: :json

      expect(response).to have_http_status(:no_content)
    end

    it 'seta deleted_at (soft delete)' do
      delete category_path(categoria), as: :json

      expect(categoria.reload.deleted_at).not_to be_nil
    end

    it 'não aparece mais no index após deletar' do
      delete category_path(categoria), as: :json
      get categories_path, headers: json_headers

      ids = response.parsed_body['data'].map { |c| c['id'] }
      expect(ids).not_to include(categoria.id)
    end

    it 'retorna 404 para id inexistente' do
      delete category_path(id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
