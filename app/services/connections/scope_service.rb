module Connections
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = build_scope
      scope = apply_filters(scope)
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

    def build_scope
      # Use unscoped for inactive queries to avoid default_scope conflicts with joins
      @params[:active] == 'false' ?
        Connection.unscoped.joins(:member, :address, :category) :
        Connection.joins(:member, :address, :category)
    end

    def apply_filters(scope)
      scope = scope.where(member_id: @params[:memberId]) if @params[:memberId].present?
      scope = scope.where(address_id: @params[:addressId]) if @params[:addressId].present?
      scope = apply_active_filter(scope) if @params[:active].present?
      scope
    end

    def apply_active_filter(scope)
      @params[:active] == 'true' ? scope.where(deleted_at: nil) : scope.where.not(deleted_at: nil)
    end

    def sort_direction
      @params[:sort_direction] == 'desc' ? 'DESC' : 'ASC'
    end
  end
end
