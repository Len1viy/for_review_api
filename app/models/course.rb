# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :enrollments
  has_many :students, through: :enrollments, class_name: "User"
  belongs_to :teacher, class_name: "User"

  scope :courses_by_student, ->(id) { where(id: Enrollment.courses_by_student(id).select(:course_id)) }
  scope :courses_by_teacher, ->(id) { where(teacher_id: id.to_i()) }
  scope :courses_by_teacher_and_student, lambda { |student_id, teacher_id|
    joins(:enrollments).where(enrollments: { user_id: student_id }).courses_by_teacher(teacher_id)
  }
  scope :limits, ->(limit, offset) { limit(limit).offset(offset) }
end