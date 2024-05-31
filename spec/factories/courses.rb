# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    title { 'Math' }
    description { 'Good' }
    teacher_id { 10 }
  end
end
