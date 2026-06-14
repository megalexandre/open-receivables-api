module InvoiceCandidates
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = Connection.includes(:member, :address, :category)
                        .joins(:member, :address, :category)
                        .without_invoice_in_period(parsed_month, parsed_year)
      scope = apply_filters(scope)
      scope.order('members.name asc')
    end

    private

    def apply_filters(scope)
      if @params[:meterType].present? && @params[:meterType] != 'all'
        hydro = @params[:meterType] == 'com_hidrometro'
        scope = scope.where(categories: { has_hydrometer: hydro })
      end

      scope = scope.where(address_id: @params[:addressId]) if @params[:addressId].present?

      scope
    end

    def parsed_month
      return Date.current.month if period.blank?

      period.split('/').first.to_i
    end

    def parsed_year
      return Date.current.year if period.blank?

      period.split('/').last.to_i
    end

    def period = @params[:period]
  end
end
