# frozen_string_literal: true

class User < ApplicationRecord
  has_many :enrollments
  has_many :student_courses, through: :enrollments, class_name: "User"
  has_many :teacher_courses, foreign_key: :teacher_id, class_name: "Course"
end