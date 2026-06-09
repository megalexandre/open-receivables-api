require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one)
  end

  test "should get index" do
    get categories_url, as: :json
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post categories_url, params: { category: {
        name: "Nova Categoria",
        group_id: @category.group_id,
        amount_water: 10.0,
        amount_partner: 5.0,
        has_hydrometer: false
      } }, as: :json
    end

    assert_response :created
  end

  test "should show category" do
    get category_url(@category), as: :json
    assert_response :success
  end

  test "should update category" do
    patch category_url(@category), params: { category: { name: "Nome Atualizado" } }, as: :json
    assert_response :success
  end

  test "should destroy category (soft delete)" do
    delete category_url(@category), as: :json
    assert_response :no_content

    @category.reload
    assert_not_nil @category.deleted_at
  end

  test "E_1_1: retorna erro ao criar categoria com nome duplicado no mesmo subgrupo" do
    post categories_url, params: { category: {
      name: @category.name,
      group_id: @category.group_id,
      amount_water: 10.0,
      amount_partner: 5.0,
      has_hydrometer: false
    } }, as: :json

    assert_response :unprocessable_entity

    body = response.parsed_body
    error = body["errors"].find { |e| e["code"] == "E_1_1" }

    assert_not_nil error, "Esperado erro com code E_1_1"
    assert_equal "E_1_1", error["code"]
    assert_includes error["message"], "O nome #{@category.name} já está associado para esse subgrupo"
  end
end
