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
    save_and_respond(new_or_reactivated_member, status: :created, serializer: MemberSerializer)
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

  def new_or_reactivated_member
    document = member_params[:document].to_s.gsub(/\D/, '')
    deleted  = Member.unscoped.where.not(deleted_at: nil).find_by(document: document)
    return Member.new(member_params) unless deleted

    deleted.assign_attributes(member_params)
    deleted.deleted_at = nil
    deleted.deleted_by = nil
    deleted
  end

  def set_member
    @member = Member.find(params.expect(:id))
  end

  def member_params
    params.expect(member: %i[name document member_number voter])
  end
end
