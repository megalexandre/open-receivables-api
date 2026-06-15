module Caixa
  class ScopeService
    # sortBy enviado pela tabela (camelCase) => coluna SQL.
    SORT_COLUMNS = {
      'paymentDate'   => 'invoices.paid_at',
      'value'         => '(COALESCE(invoices.amount_partner, 0) + COALESCE(invoices.amount_water, 0))',
      'paymentMethod' => 'invoices.payment_method',
      'number'        => 'connections.number',
      'memberName'    => 'members.name'
    }.freeze

    def initialize(params)
      @params = params
    end

    def call
      # Apenas faturas pagas (o default_scope de SoftDeletable já exclui as deletadas).
      # eager_load (LEFT JOIN) carrega member/connection e habilita ordenar por suas colunas.
      scope = Invoice.where.not(paid_at: nil).eager_load(connection: :member)
      scope = apply_filters(scope)
      sort(scope)
    end

    private

    def apply_filters(scope)
      if @params[:startDate].present?
        scope = scope.where('invoices.paid_at >= ?', @params[:startDate].to_date.beginning_of_day)
      end

      if @params[:endDate].present?
        scope = scope.where('invoices.paid_at <= ?', @params[:endDate].to_date.end_of_day)
      end

      scope = scope.where(payment_method: @params[:paymentMethod]) if @params[:paymentMethod].present?
      scope
    end

    def sort(scope)
      direction = @params[:sortOrder] == 'asc' ? 'asc' : 'desc'
      column = SORT_COLUMNS[@params[:sortBy]] || 'invoices.paid_at'
      scope.order(Arel.sql("#{column} #{direction}"))
    end
  end
end
