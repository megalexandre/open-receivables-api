module Connections
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = Connection.joins(:member, :address, :category)
      scope = scope.where("members.name LIKE ?", "%#{@params[:memberName]}%") if @params[:memberName].present?
      scope = scope.where(address_id: @params[:addressId]) if @params[:addressId].present?
      scope = scope.where(deleted_at: filter_by_active) if @params[:active].present?
      sort(scope)
    end

    def sort(scope)
      case @params[:sort_by]
      when 'member_name'   then scope.order(Arel.sql("members.name #{sort_direction}"))
      when 'address'       then scope.order(Arel.sql("addresses.name #{sort_direction}"))
      when 'active'        then scope.order(Arel.sql("connections.deleted_at #{sort_direction}"))
      when 'category_name' then scope.order(Arel.sql("categories.name #{sort_direction}"))
      when 'value'         then scope.order(Arel.sql("(categories.amount_water + categories.amount_partner) #{sort_direction}"))
      else scope.order(Arel.sql("members.name asc"))
      end
    end

    private

    def filter_by_active
      @params[:active] == 'true' ? nil : 'NOT NULL'
    end

    def sort_direction
      @params[:sort_direction] == 'desc' ? 'DESC' : 'ASC'
    end
  end
end
