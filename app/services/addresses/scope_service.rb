module Addresses
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = Address.all
      scope = scope.where(address_type: @params[:address_type]) if @params[:address_type].present?
      scope = scope.where("name LIKE ?", "%#{@params[:name]}%") if @params[:name].present?
      scope
    end

    def sort(scope)
      direction = @params[:sort_order] == 'desc' ? :desc : :asc
      case @params[:sort_by]
      when 'name'         then scope.order(name: direction)
      when 'address_type' then scope.order(address_type: direction)
      else                     scope.order(address_type: :asc, name: :asc)
      end
    end
  end
end
