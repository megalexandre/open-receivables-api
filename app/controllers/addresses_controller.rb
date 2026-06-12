class AddressesController < ApplicationController
  include Paginatable
  include Persistable
  include Destroyable

  before_action :set_address, only: %i[show update destroy]

  # GET /addresses
  def index
    render json: paginate(scope_service.call, serializer: AddressSerializer)
  end

  # GET /addresses/:id
  def show
    render json: AddressSerializer.new(@address)
  end

  # POST /addresses
  def create
    save_and_respond(Address.new(address_params), status: :created, serializer: AddressSerializer)
  end

  # PATCH/PUT /addresses/:id
  def update
    @address.assign_attributes(address_params)
    save_and_respond(@address, serializer: AddressSerializer)
  end

  # PATCH /addresses/:id/reactivate
  def reactivate
    address = Address.unscoped.find(params.expect(:id))
    address.reactivate!
    render json: AddressSerializer.new(address)
  end

  private

  def scope_service = Addresses::ScopeService.new(params)

  def apply_sort(scope) = scope_service.sort(scope)

  def resource
    @address
  end

  def set_address
    @address = Address.find(params.expect(:id))
  end

  def address_params
    params.expect(address: %i[name address_type notes])
  end
end
