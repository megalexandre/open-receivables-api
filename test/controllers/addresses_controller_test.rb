require "test_helper"

class AddressesControllerTest < ActionDispatch::IntegrationTest
  
  setup do
    @address = addresses(:rua_flores)
  end

  test "should create address" do

    assert_difference("Address.count") do
      post addresses_url, params: { address: {
        address_type: "Travessa",
        name: "Nova"
      } }, as: :json
    end

    assert_response :created

  end

  test "E_3_1: retorna erro ao criar logradouro com tipo e nome duplicados" do
    assert_no_difference("Address.count") do
      post addresses_url, params: { address: {
        address_type: @address.address_type,
        name: @address.name
      } }, as: :json
    end

    assert_response :unprocessable_entity

    body = response.parsed_body
    error = body["errors"].find { |e| e["code"] == "E_3_1" }

    assert_not_nil error, "Esperado erro com code E_3_1"
    assert_equal "name", error["field"]
  end

  test "E_3_1: retorna erro ao atualizar logradouro para tipo e nome já existentes" do
    other = addresses(:avenida_brasil)

    patch address_url(other), params: { address: {
      address_type: @address.address_type,
      name: @address.name
    } }, as: :json

    assert_response :unprocessable_entity

    body = response.parsed_body
    error = body["errors"].find { |e| e["code"] == "E_3_1" }

    assert_not_nil error, "Esperado erro com code E_3_1"
  end

  test "permite criar logradouro com mesmo nome em tipo diferente" do

    assert_difference("Address.count") do
      post addresses_url, params: { address: {
        address_type: "Avenida",
        name: @address.name
      } }, as: :json
    end

    assert_response :created
  end
end
