# frozen_string_literal: true


RSpec.describe Api::SessionController, type: :request do
  let!(:user1) do
    FactoryBot.create(:user, fullname: 'Учитель1',
                      email: 'email_teacher1@mail.ru',
                      password: BCrypt::Password.create('password1'),
                      root: 2,
                      validation_jwt: nil)
  end
  let!(:user2) do
    FactoryBot.create(:user, fullname: 'Ученик1',
                      email: 'email_student1@mail.ru',
                      password: BCrypt::Password.create('password2'),
                      root: 1,
                      validation_jwt: nil)
  end
  let!(:user3) do
    FactoryBot.create(:user, fullname: 'Ученик2',
                      email: 'email_student2@mail.ru',
                      password: BCrypt::Password.create('password3'),
                      root: 1,
                      validation_jwt: nil)
  end
  let(:token1) do
    JWT.encode({ id: user1.id,
                 email: 'email_teacher1@mail.ru',
                 password: BCrypt::Password.create('password1'),
                 root: 2,
                 created_at: Time.now },
               'SK',
               'HS256')
  end
  let(:token2) do
    JWT.encode({ id: user2.id,
                 email: 'email_student1@mail.ru',
                 password: BCrypt::Password.create('password2'),
                 root: 1,
                 created_at: Time.now },
               'SK',
               'HS256')
  end
  let(:token3) do
    JWT.encode({ id: user3.id,
                 email: 'email_student2@mail.ru',
                 password: BCrypt::Password.create('password3'),
                 root: 1,
                 created_at: Time.now },
               'SK',
               'HS256')
  end

  describe 'POST api/session tutor' do
    subject do
      post '/api/session', params: { user: { email: 'email_teacher1@mail.ru', password: 'password1' } }
      response
    end
    let (:decoded_token) { JWT.decode(JSON.parse(response.body)['jwt'], 'SK', false, { algorithm: 'HS256' }) }

    it do
      expect(subject).to have_http_status(:ok)
      expect(decoded_token[0]['id']).to eq user1.id
      expect(decoded_token[0]['email']).to eq user1.email
      expect(decoded_token[0]['root']).to eq user1.root
    end
  end

  describe 'DELETE api/session' do
    subject do
      delete '/api/session', params: {},
             headers: { 'Authorization': "Bearer #{token1}" }
    end
    it do
      expect(user1.validation_jwt).to eq nil
    end
  end

  describe 'POST api/session student' do
    subject do
      post '/api/session', params: { user: { email: 'email_student1@mail.ru', password: 'password2' } }
      response
    end

    let (:decoded_token) { JWT.decode(JSON.parse(response.body)['jwt'], 'SK', false, { algorithm: 'HS256' }) }
    it do
      expect(subject).to have_http_status(:ok)
      expect(decoded_token[0]['id']).to eq user2.id
      expect(decoded_token[0]['email']).to eq user2.email
      expect(decoded_token[0]['root']).to eq user2.root
    end

  end

  describe 'POST api/session student2' do
    subject do
      post '/api/session', params: { user: { email: 'email_student2@mail.ru', password: 'password3' } }
      response
    end

    let (:decoded_token) {JWT.decode(JSON.parse(response.body)['jwt'], 'SK', false, { algorithm: 'HS256' })}

    it do
      expect(subject).to have_http_status(:ok)
      expect(decoded_token[0]['id']).to eq user3.id
      expect(decoded_token[0]['email']).to eq user3.email
      expect(decoded_token[0]['root']).to eq user3.root
    end

  end


end
