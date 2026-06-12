module Members
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = base_scope
      scope = scope.where("name LIKE ?", "%#{@params[:name]}%") if @params[:name].present?
      scope = scope.where("document LIKE ?", "%#{@params[:document]}%") if @params[:document].present?
      scope
    end

    def sort(scope)
      direction = @params[:sort_order] == 'desc' ? :desc : :asc
      case @params[:sort_by]
      when 'name'          then scope.order(name: direction)
      when 'member_number' then scope.order(member_number: direction)
      else                      scope.order(name: :asc)
      end
    end

    private

    def base_scope
      @params[:active] == 'false' ? Member.unscoped.where.not(deleted_at: nil) : Member.all
    end
  end
end
