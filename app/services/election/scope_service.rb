module Election
  class ScopeService
    def initialize(params)
      @params = params
    end

    # Aptos a votar numa eleição realizada em `date`:
    # - membro ativo e com voter = true
    # - possui ao menos uma ligação ativa
    # - sem nenhuma fatura não paga vencida há mais de 60 dias (contados de `date`)
    #
    # Opcionalmente filtra por `member_type` (categoria da ligação:
    # Sócio Fundador / Efetivo / Temporário): nesse caso só contam ligações
    # ativas cuja categoria seja do tipo pedido.
    def call
      date        = @params[:date].present? ? Date.parse(@params[:date]) : Date.current
      cutoff      = date - 60.days
      member_type = @params[:member_type].presence

      # Ligações ativas (default_scope de Connection já filtra deleted_at: nil).
      active_connections = Connection.all
      if member_type.present?
        active_connections = active_connections
          .joins(:category)
          .where(categories: { member_type: member_type })
      end
      active_connection_members = active_connections.select(:member_id)

      # Membros com fatura não paga vencida há mais de 60 dias, em QUALQUER ligação
      # (ativa ou não). O INNER JOIN cru ignora o default_scope de Connection de
      # propósito — débito de ligação inativa também desqualifica.
      overdue_members = Invoice
        .where(paid_at: nil)
        .where('invoices.due_date < ?', cutoff)
        .joins('INNER JOIN connections ON connections.id = invoices.connection_id')
        .select('connections.member_id')

      Member
        .where(voter: true)
        .where(id: active_connection_members)
        .where.not(id: overdue_members)
        .order(:name)
    end
  end
end
