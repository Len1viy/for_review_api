# frozen_string_literal: true

class User < ApplicationRecord
  has_many :enrollments
  has_many :courses, through: :enrollments
  has_many :courses
  scope :find_user, ->(id) { where(id:) }
end
