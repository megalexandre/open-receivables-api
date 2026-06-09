require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  # ── CREATE ──────────────────────────────────────────────────────────────────

  test "cria membro com CPF válido" do
    assert_difference "Member.count", 1 do
      post members_url, params: { member: {
        name: "Novo Sócio",
        document: "12345678901",
        member_number: 99
      } }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "Novo Sócio", body["name"]
    assert_equal "12345678901", body["document"]
  end

  test "cria membro com CNPJ válido (14 dígitos)" do
    assert_difference "Member.count", 1 do
      post members_url, params: { member: {
        name: "Empresa Rural",
        document: "12345678000195",
        member_number: 98
      } }, as: :json
    end

    assert_response :created
  end

  test "retorna 422 ao criar membro sem nome" do
    assert_no_difference "Member.count" do
      post members_url, params: { member: {
        document: "12345678901"
      } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "retorna 422 ao criar membro com document menor que 11 dígitos" do
    assert_no_difference "Member.count" do
      post members_url, params: { member: {
        name: "Sócio Inválido",
        document: "1234567"
      } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "retorna 422 ao criar membro com document maior que 14 dígitos" do
    assert_no_difference "Member.count" do
      post members_url, params: { member: {
        name: "Sócio Inválido",
        document: "123456789012345"
      } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "retorna 422 ao criar membro com CPF duplicado" do
    existing = members(:ana)

    assert_no_difference "Member.count" do
      post members_url, params: { member: {
        name: "Outro Nome",
        document: existing.document
      } }, as: :json
    end

    assert_response :unprocessable_entity
    body = response.parsed_body
    assert_match(/taken|já foi tomado|já está em uso/i, body["error"])
  end

  test "document é salvo sem formatação (apenas dígitos)" do
    post members_url, params: { member: {
      name: "Sócio Formatado",
      document: "111.222.333-44"
    } }, as: :json

    assert_response :created
    assert_equal "11122233344", Member.last.document
  end

  # ── INDEX / ORDENAÇÃO ───────────────────────────────────────────────────────

  test "index retorna todos os membros" do
    get members_url, as: :json

    assert_response :success
    body = response.parsed_body
    assert body["data"].length >= 3
  end

  test "ordenação padrão é por nome ascendente" do
    get members_url, as: :json

    assert_response :success
    names = response.parsed_body["data"].map { |m| m["name"] }
    assert_equal names.sort, names
  end

  test "ordena por nome descendente com sort_order=desc" do
    get members_url, params: { sort_by: "name", sort_order: "desc" }, as: :json

    assert_response :success
    names = response.parsed_body["data"].map { |m| m["name"] }
    assert_equal names.sort.reverse, names
  end

  test "ordena por member_number ascendente" do
    get members_url, params: { sort_by: "member_number", sort_order: "asc" }, as: :json

    assert_response :success
    numbers = response.parsed_body["data"].map { |m| m["member_number"] }.compact
    assert_equal numbers.sort, numbers
  end

  test "filtra por nome parcial" do
    get members_url, params: { name: "Ana" }, as: :json

    assert_response :success
    data = response.parsed_body["data"]
    assert data.any? { |m| m["name"] == "Ana Lima" }
    assert data.none? { |m| m["name"] == "Beto Souza" }
  end

  test "filtra por document parcial" do
    get members_url, params: { document: "111" }, as: :json

    assert_response :success
    data = response.parsed_body["data"]
    assert data.all? { |m| m["document"].include?("111") }
  end

  # ── SHOW ────────────────────────────────────────────────────────────────────

  test "retorna membro pelo id" do
    member = members(:beto)
    get member_url(member), as: :json

    assert_response :success
    assert_equal member.name, response.parsed_body["name"]
  end

  # ── UPDATE ──────────────────────────────────────────────────────────────────

  test "atualiza nome do membro" do
    member = members(:ana)
    patch member_url(member), params: { member: { name: "Ana Souza" } }, as: :json

    assert_response :success
    assert_equal "Ana Souza", member.reload.name
  end

  test "retorna 422 ao atualizar com document duplicado" do
    ana = members(:ana)
    beto = members(:beto)

    patch member_url(beto), params: { member: { document: ana.document } }, as: :json

    assert_response :unprocessable_entity
  end

  # ── DESTROY ─────────────────────────────────────────────────────────────────

  test "soft delete: seta deleted_at e retorna 204" do
    member = members(:carlos)

    delete member_url(member), as: :json

    assert_response :no_content
    assert_not_nil member.reload.deleted_at
  end

  test "membro deletado não aparece no index" do
    member = members(:carlos)
    member.soft_delete!

    get members_url, as: :json

    assert_response :success
    ids = response.parsed_body["data"].map { |m| m["id"].to_i }
    assert_not_includes ids, member.id
  end
end
