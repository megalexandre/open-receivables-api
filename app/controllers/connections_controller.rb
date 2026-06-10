class ConnectionsController < ApplicationController
  include Paginatable

  before_action :set_connection, only: %i[show update destroy]

  SORTABLE_COLUMNS = %w[member_name address active category_name value].freeze

  def show
    render json: @connection
  end

  def index
    scope = Link.joins(:member, :address, :category)
    scope = scope.where("members.name LIKE ?", "%#{params[:memberName]}%") if params[:memberName].present?
    scope = scope.where(address_id: params[:addressId]) if params[:addressId].present?
    if params[:active].present?
      if params[:active] == 'true'
        scope = scope.where("links.inativo = '0' OR links.inativo = 0x00")
      else
        scope = scope.where.not("links.inativo = '0' OR links.inativo = 0x00")
      end
    end
    render json: paginate(scope)
  end

  def summary
    total     = Link.count
    active    = Link.where("inativo = '0' OR inativo = 0x00").count
    effective = Link.where("(inativo = '0' OR inativo = 0x00) AND (socio_exclusivo = '0' OR socio_exclusivo = 0x00)").count
    temporary = Link.where("(inativo = '0' OR inativo = 0x00) AND NOT (socio_exclusivo = '0' OR socio_exclusivo = 0x00)").count
    render json: { total: total, active: active, effective: effective, temporary: temporary }
  end

  def create
    link = Link.new(link_params)
    link.inativo = "\x00"
    if link.save
      render json: link, status: :created
    else
      render json: { errors: link.errors }, status: :unprocessable_content
    end
  end

  def update
    @connection.assign_attributes(link_params)
    if @connection.save
      render json: @connection
    else
      render json: { errors: @connection.errors }, status: :unprocessable_content
    end
  end

  def destroy
    @connection.update_columns(inativo: "\x01")
    head :no_content
  end

  private

  def apply_sort(scope)
    case params[:sort_by]
    when 'member_name'   then scope.order(Arel.sql("members.name #{sort_direction}"))
    when 'address'       then scope.order(Arel.sql("addresses.name #{sort_direction}"))
    when 'active'        then scope.order(Arel.sql("links.inativo #{sort_direction}"))
    when 'category_name' then scope.order(Arel.sql("categories.name #{sort_direction}"))
    when 'value'         then scope.order(Arel.sql("(categories.amount_water + categories.amount_partner) #{sort_direction}"))
    else scope.order(Arel.sql("members.name asc"))
    end
  end

  def set_connection
    @connection = Link.joins(:member, :address, :category).find(params.expect(:id))
  end

  def link_params
    params.expect(connection: %i[address_id id_pessoa id_categoria_socio
                                  numero datamatricula inativo socio_exclusivo])
  end
end
