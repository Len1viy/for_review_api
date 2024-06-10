# frozen_string_literal: true

require 'jwt'
require 'bcrypt'

class SessionService

  attr_reader :params
  def initialize(params = {})
    @params = params
  end

  def find_user(params)
    user = User.find_by(email: params[:email])
    return { data: 'Wrong email or password', status: :unauthorized } unless user
    unless BCrypt::Password.new(user.password) == params[:password]
      return { data: 'Wrong email or password', status: :unauthorized }
    end

    payload = { id: user.id, email: params[:email], password: params[:password], root: user.root,
                validation_jwt: user.validation_jwt, created_at: Time.now }
    token = (JWT.encode payload, 'SK', 'HS256')[0..-2]
    { data: token, status: :ok }
  end

  def unauth_user(validation)
    if validation != []
      user = validation[:user]
      user.validation_jwt = SecureRandom.hex(8)
      user.save
      { data: user, status: :ok }
    else
      { data: 'Unathorized 401', status: 401 }
    end
  end
end
