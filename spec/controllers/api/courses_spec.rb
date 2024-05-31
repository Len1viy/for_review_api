# frozen_string_literal: true

require 'rails_helper'
include Rails.application.routes.url_helpers

RSpec.describe Api::CoursesController, type: :request do
  let!(:valid_jwt) { SecureRandom.hex(8) }
  let!(:user1) do
    FactoryBot.create(:user, fullname: 'Учитель1',
                      email: 'email_teacher1@mail.ru',
                      password: BCrypt::Password.create('password1'),
                      root: 2,
                      validation_jwt: valid_jwt)
  end
  let!(:user2) do
    FactoryBot.create(:user, fullname: 'Ученик1',
                      email: 'email_student1@mail.ru',
                      password: BCrypt::Password.create('password2'),
                      root: 1,
                      validation_jwt: valid_jwt)
  end
  let!(:user3) do
    FactoryBot.create(:user, fullname: 'Ученик2',
                      email: 'email_student2@mail.ru',
                      password: BCrypt::Password.create('password3'),
                      root: 1,
                      validation_jwt: valid_jwt)
  end
  let!(:token1) do
    JWT.encode({ id: user1.id,
                 email: 'email_teacher1@mail.ru',
                 password: BCrypt::Password.create('password1'),
                 root: 2,
                 validation_jwt: valid_jwt,
                 created_at: Time.now },
               'SK',
               'HS256')
  end
  let!(:token2) do
    JWT.encode({ id: user2.id,
                 email: 'email_student1@mail.ru',
                 password: BCrypt::Password.create('password2'),
                 root: 1,
                 validation_jwt: valid_jwt,
                 created_at: Time.now },
               'SK',
               'HS256')
  end
  let!(:token3) do
    JWT.encode({ id: user3.id,
                 email: 'email_student2@mail.ru',
                 password: BCrypt::Password.create('password3'),
                 root: 1,
                 validation_jwt: valid_jwt,
                 created_at: Time.now },
               'SK',
               'HS256')
  end

  describe 'POST api/courses' do
    subject do
      post '/api/courses',
           params: { course: { title: 'Math', description: 'Nice subject' } }.to_json,
           headers: { Authorization: "Bearer #{token1}", "Content-Type": 'application/json' }
      response
    end
    let (:valid_ans) { { "description": 'Nice subject', "fullname": 'Учитель1' } }
    let (:parsed_response) { JSON.parse(response.body) }
    let (:course_created) { Course.find_by(teacher_id: user1.id) }
    it do
      expect(subject).to have_http_status(:ok)
      expect(parsed_response['description']).to eq valid_ans[:description]
      expect(parsed_response['fullname']).to eq valid_ans[:fullname]
      expect(course_created.title).to eq 'Math'
      expect(course_created.description).to eq 'Nice subject'
    end
  end

  let!(:course) do
    FactoryBot.create(:course,
                      title: 'Math',
                      description: 'Nice subject',
                      teacher_id: user1.id)
  end

  describe 'GET api/courses/:id' do
    subject do
      get '/api/courses?tutor_id=1', headers: { Authorization: "Bearer #{token1}", "Content-Type": 'application/json' }
      response
    end
    let (:valid_ans) { [{ 'creator' => 'Учитель1', 'description' => 'Nice subject', 'title' => 'Math' }] }
    let (:parsed_response) { JSON.parse(subject.body) }
    it 'GET api/courses?tutor_id=1' do

      expect(subject).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans
    end
  end

  describe 'POST api/courses unauthorised' do
    subject do
      delete '/api/session', params: {},
             headers: { 'Authorization': "Bearer #{token1}" }
      post '/api/courses',
           params: { course: { title: 'Math', description: 'Nice subject' } }.to_json,
           headers: { Authorization: "Bearer #{token1}", "Content-Type": 'application/json' }
      response
    end
    it do
      expect(subject).to have_http_status(401)
    end
  end

  describe 'POST api/courses student forbidden and GET api/courses' do
    subject(:post_subj) do
      post '/api/courses',
           params: { course: { title: 'Math', description: 'Nice subject' } }.to_json,
           headers: { Authorization: "Bearer #{token2}", "Content-Type": 'application/json' }
      response
    end

    subject(:get_subj) do
      get '/api/courses', headers: { Authorization: "Bearer #{token2}", "Content-Type": 'application/json' }
      response
    end
    let (:parsed_response) { JSON.parse(get_subj.body) }
    let (:valid_ans) { [{ 'creator' => 'Учитель1', 'description' => 'Nice subject', 'title' => 'Math' }] }
    let (:count_courses) { Course.count }

    it do
      expect(post_subj).to have_http_status(403)
      expect(count_courses).to eq 1
      expect(get_subj).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans
    end
  end

  describe 'GET api/courses?student_id={id студента}' do
    subject do
      get '/api/courses?student_id=2', headers: { Authorization: "Bearer #{token2}", "Content-Type": 'application/json' }
      response
    end
    let (:valid_ans) { [] }
    let (:parsed_response) { JSON.parse(subject.body) }
    it do
      expect(subject).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans

    end
  end

  describe 'POST api/cources/4/subscribe' do
    subject do
      post '/api/cources/4/subscribe',
           headers: { Authorization: "Bearer #{token2}", "Content-Type": 'application/json' }
      get '/api/courses?student_id=2', headers: { Authorization: "Bearer #{token2}", "Content-Type": 'application/json' }
      response
    end
    let (:valid_ans) { [] }
    let (:parsed_response) { JSON.parse(subject.body) }
    it do
      expect(subject).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans
    end

  end

  describe 'POST api/courses student forbidden and GET api/courses' do
    subject(:post_subj) do
      post '/api/courses',
           params: { course: { title: 'Math', description: 'Nice subject' } }.to_json,
           headers: { Authorization: "Bearer #{token3}", "Content-Type": 'application/json' }
      response
    end

    subject(:get_subj) do
      get '/api/courses', headers: { Authorization: "Bearer #{token3}", "Content-Type": 'application/json' }
      response
    end

    let (:course_count) { Course.count }
    let (:valid_ans) { [{ 'creator' => 'Учитель1', 'description' => 'Nice subject', 'title' => 'Math' }] }
    let (:parsed_response) { JSON.parse(get_subj.body) }

    it do

      expect(post_subj).to have_http_status(403)
      expect(course_count).to eq 1

      expect(get_subj).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans
    end
  end

  describe 'GET api/courses?student_id={id студента}' do
    subject do
      get '/api/courses?student_id=3', headers: { Authorization: "Bearer #{token3}", "Content-Type": 'application/json' }
      response
    end
    let (:valid_ans) { [] }
    let (:parsed_response) { JSON.parse(subject.body) }
    it do
      expect(subject).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans
    end
  end

  describe 'POST api/cources/4/subscribe' do
    subject do
      post '/api/cources/4/subscribe',
           headers: { Authorization: "Bearer #{token3}", "Content-Type": 'application/json' }
      get '/api/courses?student_id=3', headers: { Authorization: "Bearer #{token3}", "Content-Type": 'application/json' }
      response
    end

    let (:valid_ans) { [] }
    let (:parsed_response) { JSON.parse(response.body) }
    it do

      expect(subject).to have_http_status(:ok)
      expect(parsed_response).to eq valid_ans
    end
  end
end
