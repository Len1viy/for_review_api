# frozen_string_literal: true

module Api
  class RegistrationController < ApplicationController
    def index
      render json: {}
    end

    def create
      @user = User.new(user_params)
      @user.validation_jwt = SecureRandom.hex(8)
      if @user.save
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    private

    def user_params
      puts params
      if params[:user].is_a? String
        params[:user]
      else
        params.require(:user).permit(:fullname, :email, :password, :root)
      end
    end
  end
end
