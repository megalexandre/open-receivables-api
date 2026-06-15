class WaterQualityController < ApplicationController
  include Paginatable

  SORT_COLUMNS = {
    'reference'  => :reference_date,
    'parameter'  => :parameter,
    'required'   => :required_value,
    'analyzed'   => :analyzed_value,
    'conformity' => :conformity_value
  }.freeze

  def index
    scope = WaterAnalysis.all
    scope = scope.for_reference(params[:reference]) if params[:reference].present?
    render json: paginate(scope, serializer: WaterAnalysisSerializer)
  end

  def destroy
    deleted = WaterAnalysis.for_reference(params[:reference]).delete_all
    render json: { deleted: deleted }
  end

  def create
    date = Date.new(params[:year].to_i, params[:month].to_i, 1)

    ActiveRecord::Base.transaction do
      Array(params[:entries]).each do |entry|
        analysis = WaterAnalysis.new(
          parameter:       entry[:parameter],
          reference_date:  date,
          required_value:  entry[:required],
          analyzed_value:  entry[:analyzed],
          conformity_value: entry[:conformity],
        )
        unless analysis.save
          render_errors(analysis)
          raise ActiveRecord::Rollback
        end
      end
    end

    render json: { ok: true }, status: :created unless performed?
  end

  private

  def apply_sort(scope)
    column = SORT_COLUMNS[params[:sort_by]]
    return scope.order(reference_date: :desc, parameter: :asc) if column.nil?

    scope.order(column => sort_direction)
  end
end
