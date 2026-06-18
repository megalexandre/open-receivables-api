class ElectionController < ApplicationController
  def index
    members = Election::ScopeService.new(params).call

    render json: {
      data: members.map { |m| Election::MemberSerializer.new(m) },
      total: members.size,
    }
  end
end
