class InvoicesController < ApplicationController
  include Paginatable
  include Persistable
  include Destroyable

  before_action :set_invoice, only: %i[show update destroy pay unpay]

  def generate
    generate_params = params.permit(:due_date, :reference_date, candidate_ids: [])
    ids = generate_params[:candidate_ids] || []
    due_date = generate_params[:due_date]
    reference_date = generate_params[:reference_date]

    now = Time.current
    rows = Connection.where(id: ids).includes(:category).map do |conn|
      {
        connection_id: conn.id,
        due_date: due_date,
        reference_date: reference_date,
        amount_partner: conn.category.amount_partner,
        amount_water: conn.category.amount_water,
        created_at: now,
        updated_at: now
      }
    end

    # Inserção em lote (uma única query). A unicidade é garantida pelo índice
    # único (connection_id, reference_date); linhas duplicadas são ignoradas.
    Invoice.insert_all(rows) unless rows.empty?

    render json: { created: rows.size }, status: :created
  end

  def index
    render json: paginate(scope_service.call, serializer: InvoiceSerializer)
  end

  def show
    render json: InvoiceSerializer.new(@invoice)
  end

  def create
    save_and_respond(Invoice.new(invoice_params), status: :created, serializer: InvoiceSerializer)
  end

  def update
    @invoice.assign_attributes(invoice_params)
    save_and_respond(@invoice, serializer: InvoiceSerializer)
  end

  # Baixa (recebimento): registra o pagamento na data informada (ou agora).
  def pay
    @invoice.update!(paid_at: params[:paid_at].presence || Time.current)
    render json: InvoiceSerializer.new(@invoice)
  end

  # Estorno: volta a fatura para pendente.
  def unpay
    @invoice.update!(paid_at: nil)
    render json: InvoiceSerializer.new(@invoice)
  end

  private

  def scope_service = Invoices::ScopeService.new(params)

  def apply_sort(scope) = scope_service.sort(scope)

  def resource
    @invoice
  end

  def set_invoice
    @invoice = Invoice.find(params.expect(:id))
  end

  def invoice_params
    params.expect(invoice: %i[connection_id due_date reference_date paid_at amount_partner amount_water])
  end
end
