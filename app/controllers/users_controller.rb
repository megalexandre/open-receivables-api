class UsersController < ApplicationController
  def me
    render json: {
      id: "1",
      email: "admin@acal.com",
      roles: ["admin"],
      photo_url: nil
    }
  end
end
