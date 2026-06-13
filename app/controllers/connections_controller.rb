class ConnectionsController < ApplicationController
  include Paginatable
  include Persistable
  include Destroyable

  before_action :set_connection, only: %i[show update destroy]

  # GET /connections
  def index
    scope = scope_service.call
    Rails.logger.warn "🔍 CONNECTIONS - scope.count: #{scope.count}"
    render json: paginate(scope, serializer: ConnectionSerializer)
  end

  # GET /connections/:id
  def show
    render json: ConnectionSerializer.new(@connection)
  end

  # POST /connections
  def create
    save_and_respond(Connection.new(connection_params), status: :created, serializer: ConnectionSerializer)
  end

  # PATCH/PUT /connections/:id
  def update
    @connection.assign_attributes(connection_params)
    save_and_respond(@connection, serializer: ConnectionSerializer)
  end

  # GET /connections/summary
  def summary
    render json: {
      total: Connection.unscoped.count,
      active: Connection.count,
      effective: Connection.where(partner_exclusive: false).count,
      temporary: Connection.where(partner_exclusive: true).count
    }
  end

  # PATCH /connections/:id/reactivate
  def reactivate
    connection = Connection.unscoped.find(params.expect(:id))
    connection.assign_attributes(deleted_at: nil, deleted_by: nil)
    save_and_respond(connection, serializer: ConnectionSerializer)
  end

  private

  def scope_service = Connections::ScopeService.new(params)

  def apply_sort(scope) = scope_service.sort(scope)

  def resource
    @connection
  end

  def set_connection
    @connection = Connection.joins(:member, :address, :category).find(params.expect(:id))
  end

  def connection_params
    params.expect(connection: %i[address_id member_id category_id
                                  number registration_date partner_exclusive])
  end
end
