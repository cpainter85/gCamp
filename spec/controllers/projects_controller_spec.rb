require 'rails_helper'

describe ProjectsController do
  describe 'GET #index' do
    it 'should have a list of the projects a current user is a member or owner of' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      project2 = create_project(name: 'Find Jason Statham')
      project3 = create_project(name: 'Defeat Ultron')
      membership = create_membership(user, project)
      membership2 = create_membership(user, project2)

      get :index

      expect(assigns(:projects)).to eq [project, project2]
    end

    it 'should show all projects for an admin' do
      user = create_user(admin: true)
      session[:user_id] = user.id
      user2 = create_user(first_name: 'Jason', last_name: 'Statham', email: 'thetransporter@email.com', password: 'frankmartin')
      project = create_project
      project2 = create_project(name: 'Transport packages quickly')
      membership = create_membership(user2, project2)

      get :index

      expect(assigns(:admin_projects)).to eq [project, project2]

    end

    it 'should redirect to sign in path if user not logged in' do
      get :index

      expect(response).to redirect_to sign_in_path
      expect(flash[:alert]).to eq 'You must sign in'

    end
  end

  describe 'GET #new' do
    it 'should redirect to sign in path if user not logged in' do
      get :new

      expect(response).to redirect_to sign_in_path
      expect(flash[:alert]).to eq 'You must sign in'

    end

    it 'should allow logged in user to create a new project' do
      user = create_user
      session[:user_id] = user.id

      get :new

      expect(assigns(:project)).to be_a_new(Project)
    end
  end

  describe 'POST #create' do
    describe 'on success' do
      it 'creates a new project when valid params are passed and sets current user as owner' do
        user = create_user
        session[:user_id] = user.id

        expect {
          post :create, project: { name: 'Find Letty'}
          }.to change { Project.all.count }.by(1)

        project = Project.last
        expect(project.name).to eq 'Find Letty'
        expect(flash[:notice]).to eq 'Project was successfully created'
        expect(response).to redirect_to project_tasks_path(project)
        expect(user.memberships.last.role_id).to eq 2
      end
    end
    describe 'on failure' do
      it 'it should not create a new project when invalid params are passed' do
        user = create_user
        session[:user_id] = user.id

        expect {
          post :create, project: { name: nil }
        }.to_not change { Project.all.count }

        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    it 'assigns project to the corresponding project' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)

      get :show, id: project.id

      expect(assigns(:project)).to eq project
    end
  end

  describe 'GET #edit' do
    it 'allows owner to edit a project' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project, role_id: 2)

      get :edit, id: project.id

      expect(assigns(:project)).to eq project
    end
    it 'allows admin to edit a project' do
      user = create_user(admin: true)
      session[:user_id] = user.id
      project = create_project

      get :edit, id: project.id

      expect(assigns(:project)).to eq project
    end
    it 'does not allow member to edit a project' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)

      get :edit, id: project.id

      expect(response).to redirect_to project_path(project)
      expect(flash[:alert]).to eq 'You do not have access'

    end
  end

  describe 'PATCH #update' do
    it 'updates a project when owner inputs valid params' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project, role_id: 2)

      expect {
        patch :update, id: project.id,
        project: {name: 'Confront Agent Hobbs'}
      }.to change { project.reload.name }.from('Furious 7').to('Confront Agent Hobbs')

      expect(flash[:notice]).to eq 'Project was successfully updated'
      expect(response).to redirect_to project_path(project)
    end

    it 'updates a project when admin inputs valid params' do
      user = create_user(admin: true)
      session[:user_id] = user.id
      project = create_project

      expect {
        patch :update, id: project.id,
        project: {name: 'Confront Agent Hobbs'}
      }.to change { project.reload.name }.from('Furious 7').to('Confront Agent Hobbs')

      expect(flash[:notice]).to eq 'Project was successfully updated'
      expect(response).to redirect_to project_path(project)
    end
  end

  describe 'DELETE #destroy' do
    it 'allows project owner can delete a project' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project, role_id: 2)

      expect {
        delete :destroy, id: project.id
      }.to change { Project.all.count }.by(-1)

      expect(flash[:notice]).to eq 'Project was successfully deleted'
      expect(response).to redirect_to projects_path
    end

    it 'allows admin to delete a project' do
      user = create_user(admin: true)
      session[:user_id] = user.id
      project = create_project

      expect {
        delete :destroy, id: project.id
      }.to change { Project.all.count }.by(-1)

      expect(flash[:notice]).to eq 'Project was successfully deleted'
      expect(response).to redirect_to projects_path
    end
  end
end
