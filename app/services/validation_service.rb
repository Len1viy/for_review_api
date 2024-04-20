# frozen_string_literal: true

require 'jwt'

class ValidationService < ActiveInteraction::Base
  object :request,
         class: ActionDispatch::Request

  def execute
    begin
      return if request.eql? nil
      return unless request.headers.key?(:Authorization)

      token = request.headers['Authorization'][7..]
      decoded_token = JWT.decode(token, 'SK', false, { algorithm: 'HS256' })

      user = User.find_by(id: decoded_token.first['id'], email: decoded_token.first['email'])
      return nil if decoded_token.first['validation_jwt'] != user.validation_jwt


      { user: user, token: decoded_token }
    rescue JWT::DecodeError
      nil
    end
  end
end
