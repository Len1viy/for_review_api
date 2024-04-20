# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :enrollments
  has_many :users, through: :enrollments
  belongs_to :user
  scope :courses_by_student, ->(id) { where(id: Enrollment.courses_by_student(id).pluck(:course_id)) }
  scope :courses_by_teacher, ->(id) { where(user_id: id) }
  scope :courses_by_teacher_and_student, lambda { |student_id, teacher_id|
                                           joins(:enrollments).where(enrollments: { user_id: student_id }).courses_by_teacher(teacher_id)
                                         }
  scope :limits, ->(limit, offset) { limit(limit).offset(offset) }
end
