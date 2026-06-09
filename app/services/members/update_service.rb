module Members
  class UpdateService
    def initialize(member, params)
      @member = member
      @params = params
    end

    def call
      @member.update(@params)
      self
    end

    def success? = @member.errors.none?
    def member   = @member
    def error    = @member.errors.full_messages.join(', ')
  end
end
