class MembersController < ApplicationController
  include Paginatable
  include Persistable

  before_action :set_member, only: %i[show update destroy]

  def index
    render json: paginate(scope_service.call, serializer: MemberSerializer)
  end

  def show
    render json: MemberSerializer.new(@member)
  end

  def create
    save_and_respond(Member.new(member_params), status: :created)
  end

  def update
    @member.assign_attributes(member_params)
    save_and_respond(@member)
  end

  def destroy
    @member.soft_delete!
    head :no_content
  end

  private

  def scope_service = Members::ScopeService.new(params)

  def apply_sort(scope) = scope_service.sort(scope)

  def set_member
    @member = Member.find(params.expect(:id))
  end

  def member_params
    params.expect(member: %i[name document member_number voter])
  end
end
