class AddressesController < ApplicationController
  include Paginatable
  include Persistable
  include Destroyable

  before_action :set_address, only: %i[show update destroy]

  SORTABLE_COLUMNS = %w[name address_type].freeze

  def index
    scope = Address.all
    scope = scope.where(address_type: params[:address_type]) if params[:address_type].present?
    scope = scope.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
    render json: paginate(scope)
  end

  def show
    render json: @address
  end

  def create
    save_and_respond(Address.new(address_params), status: :created)
  end

  def update
    @address.assign_attributes(address_params)
    save_and_respond(@address)
  end

  private

  def resource
    @address
  end

  def apply_sort(scope)
    column = params[:sort_by]

    case column
    when *SORTABLE_COLUMNS
      scope.order(column => sort_direction)
    else
      scope.order(address_type: :asc, name: :asc)
    end
  end

  def set_address
    @address = Address.find(params.expect(:id))
  end

  def address_params
    params.expect(address: %i[name address_type notes])
  end
end
