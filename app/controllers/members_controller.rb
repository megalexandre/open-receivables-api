class MembersController < ApplicationController
  include Paginatable
  include Persistable
  include Destroyable

  before_action :set_member, only: %i[show update destroy]

  def index
    render json: paginate(scope_service.call, serializer: MemberSerializer)
  end

  def show
    render json: MemberSerializer.new(@member)
  end

  def create
    save_and_respond(Member.new(member_params), status: :created, serializer: MemberSerializer)
  end

  def update
    @member.assign_attributes(member_params)
    save_and_respond(@member, serializer: MemberSerializer)
  end

  # PATCH /members/:id/reactivate
  def reactivate
    member = Member.unscoped.find(params.expect(:id))
    member.reactivate!
    render json: MemberSerializer.new(member)
  end

  private

  def scope_service = Members::ScopeService.new(params)

  def apply_sort(scope) = scope_service.sort(scope)

  def resource = @member

  def set_member
    @member = Member.find(params.expect(:id))
  end

  def member_params
    params.expect(member: %i[name document member_number voter])
  end
end
