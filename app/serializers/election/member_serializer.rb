module Election
  # Membro apto a votar, no formato esperado pela tela de eleição do app
  # (Member.fromJson). Mantido separado do MemberSerializer genérico para que
  # a feature de eleição possa evoluir seus campos sem afetar os demais usos.
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
end
