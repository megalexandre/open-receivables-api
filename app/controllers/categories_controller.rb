class CategoriesController < ApplicationController
  include Paginatable
  include Persistable
  include Destroyable

  before_action :set_category, only: %i[show update destroy]

  SORTABLE_COLUMNS = %w[name member_type has_hydrometer amount_water amount_partner].freeze

  def index
    render json: paginate(base_scope)
  end

  def show
    render json: @category
  end

  def create
    save_and_respond(Category.new(category_params), status: :created)
  end

  def update
    @category.assign_attributes(category_params)
    save_and_respond(@category)
  end

  # PATCH /categories/:id/reactivate
  def reactivate
    category = Category.unscoped.find(params.expect(:id))
    category.reactivate!
    render json: category
  end

  private

  def base_scope
    params[:active] == 'false' ? Category.unscoped.where.not(deleted_at: nil) : Category.all
  end

  def resource
    @category
  end

  def apply_sort(scope)
    case params[:sort_by]
    when *SORTABLE_COLUMNS
      scope.order(params[:sort_by] => sort_direction)
    when 'total'
      scope.order(Arel.sql("amount_water + amount_partner #{sort_direction}"))
    else
      scope.order(name: :asc)
    end
  end

  def set_category
    @category = Category.find(params.expect(:id))
  end

  def category_params
    params.expect(category: %i[name descricao amount_water amount_partner has_hydrometer member_type])
  end
end
