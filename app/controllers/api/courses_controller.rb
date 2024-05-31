# frozen_string_literal: true

require 'jwt'

module Api
  class CoursesController < ApplicationController
    before_action :check_user_auth
    before_action :create_service
    def index
      render json: @service.index
    end

    def show
      ans = @service.show
      return render json: ans[:json] if ans.key?(:json)

      render json: {} unless ans.key?(:json)
    end

    def subscribe
      result = @service.subscribe
      render json: result[:data], status: result[:status]
    end

    def create
      result = @service.create_course(course_params)
      render json: result[:data], status: result[:status]
    end

    private

    def check_user_auth
      val = ValidationService.run!(request:request)
      return unless val

      @user = val[:user]
      @token = val[:token]
    end

    def create_service
      @service = CoursesService.new(@user, params) if @user
      render json: { error: "User doesn't exist" }, status: :unauthorized unless @user
    end

    def course_params
      params.require(:course).permit(:title, :description)
    end
  end
end
