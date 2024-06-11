# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_access_control_headers

  def set_access_control_headers
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type'
  end
end
