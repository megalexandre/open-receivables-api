class WaterQualityController < ApplicationController
  include Paginatable

  SORTABLE_COLUMNS = %w[reference parameter required analyzed conformity].freeze

  def index
    scope = WaterAnalysis.all
    if params[:reference].present?
      parts = params[:reference].split('/')
      scope = scope.where(
        'MONTH(reference_date) = ? AND YEAR(reference_date) = ?',
        parts[0].to_i, parts[1].to_i
      )
    end
    render json: paginate(scope, serializer: WaterAnalysisSerializer)
  end

  def destroy
    parts = params[:reference].to_s.split('/')
    deleted = WaterAnalysis.where(
      'MONTH(reference_date) = ? AND YEAR(reference_date) = ?',
      parts[0].to_i, parts[1].to_i
    ).delete_all
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
    case params[:sort_by]
    when 'reference'  then scope.order(reference_date: sort_direction)
    when 'parameter'  then scope.order(parameter: sort_direction)
    when 'required'   then scope.order(required_value: sort_direction)
    when 'analyzed'   then scope.order(analyzed_value: sort_direction)
    when 'conformity' then scope.order(conformity_value: sort_direction)
    else scope.order(reference_date: :desc, parameter: :asc)
    end
  end
end
