class MemberSerializer
  
  def initialize(member)
    @member = member
  end

  def as_json(*)
    {
      id:            @member.id,
      name:          @member.name,
      document:      @member.document,
      member_number: @member.member_number,
      voter:         @member.voter,
      active:        @member.deleted_at.nil?,
    }
  end
end
