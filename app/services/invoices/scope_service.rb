module Invoices
  class ScopeService
    def initialize(params)
      @params = params
    end

    def call
      scope = Invoice.includes(connection: %i[member address])
      scope = apply_filters(scope)
      sort(scope)
    end

    def sort(scope)
      sort_by = @params[:sortBy] || 'due_date'
      sort_direction = @params[:sortOrder] == 'asc' ? 'asc' : 'desc'

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
      scope = scope.where(id: @params[:number]) if @params[:number].present?

      if @params[:member_id].present?
        scope = scope.where(connections: { member_id: @params[:member_id] }).references(:connection)
      end

      if @params[:address_id].present?
        scope = scope.where(connections: { address_id: @params[:address_id] }).references(:connection)
      end

      if @params[:paid].present?
        scope = @params[:paid] == 'true' ? scope.where.not(paid_at: nil) : scope.where(paid_at: nil)
      end

      if @params[:competencia].present?
        month, year = @params[:competencia].split('/')
        scope = scope.where(
          'MONTH(invoices.reference_date) = ? AND YEAR(invoices.reference_date) = ?',
          month.to_i, year.to_i
        )
      end

      scope = scope.where(reference_date: @params[:reference_date]) if @params[:reference_date].present?
      scope = scope.where(due_date: @params[:due_date]) if @params[:due_date].present?

      if @params[:due_date_from].present?
        scope = scope.where('invoices.due_date >= ?', @params[:due_date_from])
      end

      scope = scope.where('invoices.due_date <= ?', @params[:due_date_to]) if @params[:due_date_to].present?

      scope
    end
  end
end
