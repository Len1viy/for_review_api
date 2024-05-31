# frozen_string_literal: true

require 'jwt'
require 'bcrypt'
module Api
  class SessionController < ApplicationController
    before_action :set_user, only: %i[show update destroy]
    before_action :set_access_control_headers
    before_action :create_service
    def index
      render json: @user, status: :ok
    end

    def show
      render json: @user
    end

    def create
      ans =  @service.find_user(user_params)
      render json: { jwt: ans[:data] }, status: ans[:status]
    end

    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      validation = ValidationService.run!(request: request)
      result = @service.unauth_user(validation)
      render json: result[:data], status: result[:status]
    end


    private

    def create_service
      @service = SessionService.new
    end

    def set_user
      @user = (User.find(params[:id]) if params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end

    def set_access_control_headers
      headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type'
    end
  end
end
