# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    fullname { 'Учитель1' }
    sequence(:email) { |seq| "email_teacher#{seq}@test.test" }.
    password { 'password1' }
    root { 2 }
  end
end
