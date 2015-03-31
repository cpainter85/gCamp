require 'rails_helper'

describe UsersController do
  let!(:user) { create_user }

  describe 'if user is not signed in' do
    all_pages = ['get :index',
      'get :new',
      'post :create',
      'get :show, id: user.id',
      'get :edit, id: user.id',
      'patch :update, id: user.id',
      'delete :destroy, id: user.id']
    all_pages.each do |page|
      it 'redirects to sign in page with an error message' do
        eval(page)
        expect(response).to redirect_to sign_in_path
        expect(flash[:alert]).to eq('You must sign in')
      end
    end
  end

  RSpec.shared_examples 'common index, new, create, and show behavior' do

    describe 'GET #index' do
      it 'should assign users object with all users for logged in user' do

        get :index
        expect(assigns(:users)).to eq [user, @user2]
      end
    end
    describe 'GET #new' do
      it 'should create a new user' do

        get :new

        expect(assigns(:user)).to be_a_new(User)
      end
    end
    describe 'POST #create' do
      describe 'on success' do
        it 'create a new user when valid params are passed' do

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

          expect {
            post :create, user: { first_name: nil, last_name: nil, email: nil, password: nil}
          }.to_not change { User.all.count }

          expect(response).to render_template :new
        end
      end
    end
    describe 'GET #show' do
      it 'assigns user to the corresponding user' do

        get :show, id: user.id

        expect(assigns(:user)).to eq user
      end
    end
  end

  describe 'logged in user' do
    before :each do
      session[:user_id] = user.id
      @user2 = create_user(first_name: 'Thor', last_name: 'Odinson', email: 'godofthunder', password: 'mjolnir')
    end

    describe 'index, new, create and show actions' do
      it_behaves_like 'common index, new, create, and show behavior'
    end
    describe 'get #edit' do
      it 'allows user to edit themself' do

        get :edit, id: user.id

        expect(assigns(:user)).to eq user
      end
      it 'does not allow non-admin user to edit a different user' do

        get :edit, id: @user2.id

        expect(response.status).to eq 404
      end
    end
    describe 'patch #update' do
      it 'updates a user when user updates their own information' do

        expect {
          patch :update, id: user.id,
          user: {email: 'iamgroot@email.com'}
        }.to change { user.reload.email }.from('vindiesel@email.com').to('iamgroot@email.com')

        expect(flash[:notice]).to eq 'User was successfully updated.'
        expect(response).to redirect_to users_path
      end
      it 'does not allow non-admin to update another user\'s info' do

        expect {
          patch :update, id: @user2.id,
          user: {first_name: 'Kal', last_name: 'El'}
        }.to_not change { @user2.reload.full_name }

        expect(response.status).to eq 404

      end
    end
    describe 'DELETE #delete' do
      it 'allows a user to delete themself' do

        expect {
          delete :destroy, id: user.id
        }.to change { User.all.count }.by(-1)

        expect(session[:user_id]).to eq nil
        expect(flash[:notice]).to eq 'User was successfully deleted.'
        expect(response).to redirect_to root_path

      end
      it 'does not allow a user to delete another user' do

        expect {
          delete :destroy, id: @user2.id
        }.to_not change { User.all.count }

        expect(response.status).to eq 404

      end
    end
  end

  describe 'admin' do
    before :each do
      user.update_attributes(admin: true)
      session[:user_id] = user.id
      @user2 = create_user(first_name: 'Thor', last_name: 'Odinson', email: 'godofthunder', password: 'mjolnir')
    end
    describe 'index, new, create and show actions' do
      it_behaves_like 'common index, new, create, and show behavior'
    end
    describe 'GET #edit' do
      it 'allows admin to edit any user' do

        get :edit, id: @user2.id

        expect(assigns(:user)).to eq @user2
      end
    end
    describe 'PATCH #update' do
      describe 'on success' do
        it 'updates a user when admin inputs valid params' do

          expect {
            patch :update, id: @user2.id,
            user: {first_name: 'Ethan', last_name: 'Crane', email: 'supreme@email.com', password: 'alanmoore'}
          }.to change {@user2.reload.full_name}.from('Thor Odinson').to('Ethan Crane')

          expect(flash[:notice]).to eq 'User was successfully updated.'
          expect(response).to redirect_to users_path
        end
      end
      describe 'on failure' do
        it 'does not update a user when admin inputs invalid params' do

          expect {
            patch :update, id: @user2.id,
            user: {first_name: nil}
          }.to_not change {@user2.reload.first_name}

          expect(response).to render_template :edit
        end
      end
    end
    describe 'DELETE #destroy' do
      it 'allows an admin to delete a user' do

        expect {
          delete :destroy, id: @user2.id
        }.to change { User.all.count }.by(-1)

        expect(flash[:notice]).to eq 'User was successfully deleted.'
        expect(response).to redirect_to users_path

      end
    end
  end
end
