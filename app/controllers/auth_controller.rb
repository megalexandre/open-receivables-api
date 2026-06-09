class AuthController < ApplicationController
  MOCK_SECRET = "mock_secret"
  MOCK_USER = { id: "1", email: "admin@acal.com", roles: ["admin"] }.freeze

  def login
    username = params[:username]
    password = params[:password]

    unless username.present? && password.present?
      return render json: { error: "Credenciais inválidas" }, status: :unauthorized
    end

    render json: build_token_response
  end

  def refresh
    refresh_token = params[:refresh_token]

    unless refresh_token.present?
      return render json: { error: "Refresh token ausente" }, status: :unauthorized
    end

    render json: build_token_response
  end

  private

  def build_token_response
    now = Time.now.to_i
    payload = {
      sub: MOCK_USER[:id],
      email: MOCK_USER[:email],
      roles: MOCK_USER[:roles],
      iat: now,
      exp: now + 8.hours.to_i
    }

    access_token = JWT.encode(payload, MOCK_SECRET, "HS256")
    refresh_token = JWT.encode({ sub: MOCK_USER[:id], exp: now + 7.days.to_i }, MOCK_SECRET, "HS256")

    {
      token: access_token,
      refresh_token: refresh_token,
      token_type: "Bearer"
    }
  end
end
