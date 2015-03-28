require 'rails_helper'

describe UsersController do
  describe 'GET #index' do
    it 'should assign users object with all users for logged in user' do
      user = create_user
      user2 = create_user(first_name: 'Ragnar', last_name: 'Lothbrook', email: 'vikings@email.com', password: 'viking')
      session[:user_id] = user.id

      get :index
      expect(assigns(:users)).to eq [user, user2]
    end
    it 'should redirect non-logged in users to sign-in path' do
      get :index

      expect(response).to redirect_to sign_in_path
      expect(flash[:alert]).to eq 'You must sign in'
    end
  end
  describe 'GET #new' do
    it 'should allow logged in user to create a new user' do
      user = create_user
      session[:user_id] = user.id

      get :new

      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    describe 'on success' do
      it 'create a new user when valid params are passed' do
        user = create_user
        session[:user_id] = user.id

        expect {
          post :create, user: { first_name: 'Cobra', last_name: 'Commander', email: 'cobra@email.com', password: 'destroyGIJoe'}
        }.to change { User.all.count }.by(1)

        user = User.last
        expect(user.first_name).to eq 'Cobra'
        expect(user.last_name).to eq 'Commander'
        expect(user.email).to eq 'cobra@email.com'
        expect(response).to redirect_to users_path
        expect(flash[:notice]).to eq 'User was successfully created.'
      end
    end
    describe 'on failure' do
      it 'it should not create a user when invalid params are passed' do
        user = create_user
        session[:user_id] = user.id

        expect {
          post :create, user: { first_name: nil, last_name: nil, email: nil, password: nil}
        }.to_not change { User.all.count }

        expect(response).to render_template :new
      end
    end
  end
  describe 'GET #show' do
    it 'assigns user to the corresponding user' do
      user = create_user
      session[:user_id] = user.id

      get :show, id: user.id

      expect(assigns(:user)).to eq user
    end
  end
  describe 'GET #edit' do
    it 'allows user to edit themself' do
      user = create_user
      session[:user_id] = user.id

      get :edit, id: user.id

      expect(assigns(:user)).to eq user
    end
    it 'allows admin to edit any user' do
      user = create_user(admin: true)
      user2 = create_user(first_name: 'Thor', last_name: 'Odinson', email: 'godofthunder', password: 'mjolnir')
      session[:user_id] = user.id

      get :edit, id: user2.id

      expect(assigns(:user)).to eq user2
    end
    it 'does not allow non-admin user to edit a different user' do
      user = create_user
      user2 = create_user(first_name: 'Thor', last_name: 'Odinson', email: 'godofthunder', password: 'mjolnir')
      session[:user_id] = user.id

      get :edit, id: user2.id

      expect(response.status).to eq 404
    end
  end
  describe 'PATCH #update' do
    it 'updates a user when admin inputs valid params' do
      user = create_user(admin: true)
      user2 = create_user(first_name: 'Clark', last_name: 'Kent', email: 'superman@email.com', password: 'lastsonofkrypton')
      session[:user_id] = user.id

      expect {
        patch :update, id: user2.id,
        user: {first_name: 'Ethan', last_name: 'Crane', email: 'supreme@email.com', password: 'alanmoore'}
      }.to change {user2.reload.full_name}.from('Clark Kent').to('Ethan Crane')

      expect(flash[:notice]).to eq 'User was successfully updated.'
      expect(response).to redirect_to users_path
    end
    it 'updates a user when user updates their own information' do
      user = create_user
      session[:user_id] = user.id

      expect {
        patch :update, id: user.id,
        user: {email: 'iamgroot@email.com'}
      }.to change { user.reload.email }.from('vindiesel@email.com').to('iamgroot@email.com')

      expect(flash[:notice]).to eq 'User was successfully updated.'
      expect(response).to redirect_to users_path
    end
    it 'does not allow non-admin to update another user\'s info' do
      user = create_user
      user2 = create_user(first_name: 'Clark', last_name: 'Kent', email: 'superman@email.com', password: 'lastsonofkrypton')
      session[:user_id] = user.id

      expect {
        patch :update, id: user2.id,
        user: {first_name: 'Kal', last_name: 'El'}
      }.to_not change { user2.reload.full_name }

      expect(response.status).to eq 404

    end
    it 'does not update a user when admin inputs invalid params' do
      user = create_user(admin: true)
      user2 = create_user(first_name: 'Clark', last_name: 'Kent', email: 'superman@email.com', password: 'lastsonofkrypton')
      session[:user_id] = user.id

      expect {
        patch :update, id: user2.id,
        user: {first_name: nil}
      }.to_not change {user2.reload.first_name}

      expect(response).to render_template :edit
    end
  end
  describe 'DELETE #destroy' do
    it 'allows an admin to delete a user' do
      user = create_user(admin: true)
      session[:user_id] = user.id
      user2 = create_user(first_name: 'Bruce', last_name: 'Wayne', email: 'batman@email.com', password: 'thedarkknight')

      expect {
        delete :destroy, id: user2.id
      }.to change { User.all.count }.by(-1)

      expect(flash[:notice]).to eq 'User was successfully deleted.'
      expect(response).to redirect_to users_path

    end
    it 'allows a user to delete themself' do
      user = create_user(admin: true)
      session[:user_id] = user.id

      expect {
        delete :destroy, id: user.id
      }.to change { User.all.count }.by(-1)

      expect(session[:user_id]).to eq nil
      expect(flash[:notice]).to eq 'User was successfully deleted.'
      expect(response).to redirect_to root_path

    end
    it 'does not allow a user to delete another user' do
      user = create_user
      session[:user_id] = user.id
      user2 = create_user(first_name: 'Bruce', last_name: 'Wayne', email: 'batman@email.com', password: 'thedarkknight')

      expect {
        delete :destroy, id: user2.id
      }.to_not change { User.all.count }

      expect(response.status).to eq 404

    end
  end
end
