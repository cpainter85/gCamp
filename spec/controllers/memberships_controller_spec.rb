require 'rails_helper'

describe MembershipsController do
  describe 'GET #index' do
    it 'should have a new membership object' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)

      get :index, project_id: project.id

      expect(assigns(:membership)).to be_a_new(Membership)

    end
  end

  describe 'GET #create' do
    it 'creates a new membership if user is an owner' do
      user = create_user
      user2 = create_user(first_name: 'Walter', last_name: 'White', email: 'breakingbad@email.com', password: 'heisenberg')
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project, role_id: 2)

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
    it 'creates a new membership if user is an admin' do
      user = create_user(admin: true)
      user2 = create_user(first_name: 'Walter', last_name: 'White', email: 'breakingbad@email.com', password: 'heisenberg')
      session[:user_id] = user.id
      project = create_project

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
    it 'redirects a member who is not an owner or admin to projects path' do
      user = create_user
      user2 = create_user(first_name: 'Walter', last_name: 'White', email: 'breakingbad@email.com', password: 'heisenberg')
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)

      expect {
        post :create, project_id: project.id,
        membership: {user_id: user2.id, project_id: project.id, role_id: 1}
      }.to_not change { Membership.all.count }

      expect(flash[:alert]).to eq 'You do not have access'
      expect(response).to redirect_to project_path(project)
    end
  end

  describe 'GET #destroy' do
    it 'allows owner to destroy membership' do
      user = create_user
      user2 = create_user(first_name: 'Walter', last_name: 'White', email: 'breakingbad@email.com', password: 'heisenberg')
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project, role_id: 2)
      membership2 = create_membership(user2, project)

      expect {
        delete :destroy, project_id: project.id, id: membership2.id
      }.to change { Membership.all.count }.by(-1)

      expect(flash[:notice]).to eq "#{membership2.user.full_name} was successfully removed"
      expect(response).to redirect_to project_memberships_path(project)

    end
    it 'allows admin to destroy membership' do
      user = create_user(admin: true)
      user2 = create_user(first_name: 'Walter', last_name: 'White', email: 'breakingbad@email.com', password: 'heisenberg')
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user2, project)

      expect {
        delete :destroy, project_id: project.id, id: membership.id
      }.to change { Membership.all.count }.by(-1)

      expect(flash[:notice]).to eq "#{membership.user.full_name} was successfully removed"
      expect(response).to redirect_to project_memberships_path(project)

    end
    it 'allows member to destroy their own membership' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)

      expect {
        delete :destroy, project_id: project.id, id: membership.id
      }.to change { Membership.all.count }.by(-1)

      expect(flash[:notice]).to eq "#{membership.user.full_name} was successfully removed"
      expect(response).to redirect_to projects_path

    end
    it 'does not allow member to destroy someone else\'s membership\'s' do
      user = create_user
      session[:user_id] = user.id
      user2 = create_user(first_name: 'Walter', last_name: 'White', email: 'breakingbad@email.com', password: 'heisenberg')
      project = create_project
      membership = create_membership(user, project)
      membership2 = create_membership(user2, project)

      expect {
        delete :destroy, project_id: project.id, id: membership2.id
      }.to_not change { Membership.all.count }

      expect(flash[:alert]).to eq "You do not have access"
      expect(response).to redirect_to project_path(project)

    end
  end
end
