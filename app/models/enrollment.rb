# frozen_string_literal: true

class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  scope :courses_by_student, ->(id) { where(user_id: id) }
end
