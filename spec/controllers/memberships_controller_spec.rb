require 'rails_helper'

describe MembershipsController do

  let(:user) { create_user }
  let(:admin) { create_user(
    first_name: 'Wilson',
    last_name: 'Fisk',
    email: 'kingpin@email.com',
    password: 'kingpinofcrime',
    admin: true) }
  let(:user2) { create_user(first_name: 'Walter',
    last_name: 'White',
    email: 'breakingbad@email.com',
    password: 'heisenberg') }
  let(:project) { create_project }
  let!(:membership) { create_membership(user, project) }

  describe 'if user is not signed in' do
    all_pages = ['get :index, project_id: project.id',
       'post:create, project_id: project.id',
       'patch :update, project_id: project.id, id: membership.id',
       'delete :destroy, project_id: project.id, id: membership.id']
    all_pages.each do |page|
      it "redirects to sign in page with an error message" do
        eval(page)
        expect(response).to redirect_to sign_in_path
        expect(flash[:alert]).to eq('You must sign in')
      end
    end
  end

  RSpec.shared_examples 'admin and owner behavior' do

    describe 'GET #index' do
      it 'should have a new membership object' do
        get :index, project_id: project.id

        expect(assigns(:membership)).to be_a_new(Membership)
      end
    end

    describe 'POST #create' do
      it 'creates a new membership' do

        expect {
          post :create, project_id: project.id,
          membership: {user_id: user2.id, project_id: project.id, role_id: 1}
        }.to change { Membership.all.count }.by(1)

        membership = Membership.last
        expect(membership.user_id).to eq user2.id
        expect(membership.role_id).to eq 1
        expect(membership.project_id).to eq project.id
        expect(flash[:notice]).to eq "#{membership.user.full_name} was successfully added"
        expect(response).to redirect_to project_memberships_path(project)
      end
    end

    describe 'PATCH #update' do
      it 'allows admin to update membership' do
        membership2 = create_membership(user2, project)
        expect {
          patch :update, project_id: project.id, id: membership2.id,
          membership: {role_id: 2}
        }.to change { membership2.reload.role_id}.from(1).to(2)
      end
    end

    describe 'DELETE #destroy' do
      it 'allows admin to destroy membership' do
        membership2 = create_membership(user2, project)

        expect {
          delete :destroy, project_id: project.id, id: membership2.id
        }.to change { Membership.all.count }.by(-1)

        expect(flash[:notice]).to eq "#{membership2.user.full_name} was successfully removed"
        expect(response).to redirect_to project_memberships_path(project)
      end
    end
  end

  describe 'if user is admin' do
    before :each do
      session[:user_id] = admin.id
    end
    describe 'all pages' do
      it_behaves_like 'admin and owner behavior'
    end
  end

  describe 'if user is owner' do
    before :each do
      membership.update_attributes(role_id: 2)
      session[:user_id] = user.id
    end
    describe 'all pages' do
      it_behaves_like 'admin and owner behavior'
    end
  end

  describe 'if user is a project member' do

    before :each do
      session[:user_id] = user.id
    end

    describe 'GET #index' do
      it 'should have a new membership object' do
        get :index, project_id: project.id

        expect(assigns(:membership)).to be_a_new(Membership)
      end
    end

    describe 'GET #create' do
      it 'redirects a member who is not an owner or admin to projects path' do

        expect {
          post :create, project_id: project.id,
          membership: {user_id: user2.id, project_id: project.id, role_id: 1}
        }.to_not change { Membership.all.count }

        expect(flash[:alert]).to eq 'You do not have access'
        expect(response).to redirect_to project_path(project)
      end
    end
    describe 'DELETE #destroy' do
      it 'allows member to destroy their own membership' do

        expect {
          delete :destroy, project_id: project.id, id: membership.id
        }.to change { Membership.all.count }.by(-1)

        expect(flash[:notice]).to eq "#{membership.user.full_name} was successfully removed"
        expect(response).to redirect_to projects_path
      end

      it 'does not allow member to destroy someone else\'s membership\'s' do
        membership2 = create_membership(user2, project)

        expect {
          delete :destroy, project_id: project.id, id: membership2.id
        }.to_not change { Membership.all.count }

        expect(flash[:alert]).to eq "You do not have access"
        expect(response).to redirect_to project_path(project)

      end
    end
  end

  describe 'if user is not a project member' do
    before :each do
      session[:user_id] = user2.id
    end

    all_pages = ['get :index, project_id: project.id',
       'post:create, project_id: project.id',
       'patch :update, project_id: project.id, id: membership.id',
       'delete :destroy, project_id: project.id, id: membership.id']
    all_pages.each do |page|
      it "redirects to project page with an error message" do
        eval(page)
        expect(response).to redirect_to projects_path
        expect(flash[:alert]).to eq('You do not have access to that project')
      end
    end
  end

end
