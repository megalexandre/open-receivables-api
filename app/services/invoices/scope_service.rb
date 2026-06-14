module Invoices
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = Invoice.all
      scope = apply_filters(scope)
      sort(scope)
    end

    def sort(scope)
      sort_by = @params[:sort_by] || 'due_date'
      sort_direction = @params[:sort_ascending] == 'true' ? 'asc' : 'desc'

      case sort_by
      when 'connection_id'
        scope.order(Arel.sql("invoices.connection_id #{sort_direction}"))
      when 'due_date'
        scope.order(Arel.sql("invoices.due_date #{sort_direction}"))
      when 'reference_date'
        scope.order(Arel.sql("invoices.reference_date #{sort_direction}"))
      when 'paid_at'
        scope.order(Arel.sql("invoices.paid_at #{sort_direction}"))
      else
        scope.order(due_date: sort_direction)
      end
    end

    private

    def apply_filters(scope)
      scope = scope.where(connection_id: @params[:connection_id]) if @params[:connection_id].present?

      if @params[:paid].present?
        scope = @params[:paid] == 'true' ? scope.where.not(paid_at: nil) : scope.where(paid_at: nil)
      end

      scope = scope.where(reference_date: @params[:reference_date]) if @params[:reference_date].present?

      if @params[:due_date_from].present?
        scope = scope.where('invoices.due_date >= ?', @params[:due_date_from])
      end

      scope = scope.where('invoices.due_date <= ?', @params[:due_date_to]) if @params[:due_date_to].present?

      scope
    end
  end
end
