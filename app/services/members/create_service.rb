module Members
  class CreateService
    def initialize(params)
      @member = Member.new(params)
    end

    def call
      @member.save
      self
    end

    def success? = @member.errors.none?
    def member   = @member
    def error    = @member.errors.full_messages.join(', ')
  end
end
