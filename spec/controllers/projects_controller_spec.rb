require 'rails_helper'

describe ProjectsController do
  let(:user) { create_user }
  let(:project) { create_project }
  let!(:membership) { create_membership(user, project) }


  describe 'if user is not signed in' do
    all_pages = ['get :index', 'get :new', 'post :create',
      'get :show, id: project.id',
      'get :edit, id: project.id',
      'patch :update, id: project.id',
      'delete :destroy, id: project.id']
    all_pages.each do |page|
      it 'redirects to sign in page with an error message' do
        eval(page)
        expect(response).to redirect_to sign_in_path
        expect(flash[:alert]).to eq('You must sign in')
      end
    end
  end

  RSpec.shared_examples 'shared behavior for index' do

    describe 'GET #index' do
      it 'should have a list of the projects a current user is a member or owner of' do
        project2 = create_project(name: 'Find Jason Statham')
        project3 = create_project(name: 'Defeat Ultron')
        membership2 = create_membership(user, project2)

        get :index

        expect(assigns(:projects)).to eq [project, project2]
      end
    end
  end

  RSpec.shared_examples 'shared behavior for new and create' do
    describe 'GET #new' do
      it 'should allow logged in user to create a new project' do

        get :new

        expect(assigns(:project)).to be_a_new(Project)
      end
    end
    describe 'POST #create' do
      describe 'on success' do
        it 'creates a new project when valid params are passed and sets current user as owner' do

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

          expect {
            post :create, project: { name: nil }
          }.to_not change { Project.all.count }

          expect(response).to render_template :new
        end
      end
    end
  end

  describe 'logged in user' do
    before :each do
      session[:user_id] = user.id
    end
    describe 'GET #index' do
      it_behaves_like 'shared behavior for index'
    end
    describe 'GET #new and POST #create' do
      it_behaves_like 'shared behavior for new and create'
    end
    describe 'GET #show, GET #edit, PATCH #update, DELETE #destroy' do
      it 'redirects non member to projects path and flashes error ' do
        membership.destroy

        pages = ['get :show', 'get :edit', 'patch :update', 'delete :destroy']
        pages.each do |page|
          page << ', id: project.id'
          eval(page)

          expect(flash[:alert]).to eq 'You do not have access to that project'
          expect(response).to redirect_to projects_path
        end
      end
    end
  end

  RSpec.shared_examples 'shared behavior for show' do
    it 'assigns project to the corresponding project' do

      get :show, id: project.id

      expect(assigns(:project)).to eq project
    end
  end

  describe 'if user is project member' do
    before :each do
      session[:user_id] = user.id
    end
    describe 'GET #index' do
      it_behaves_like 'shared behavior for index'
    end
    describe 'GET #new and POST #create' do
      it_behaves_like 'shared behavior for new and create'
    end
    describe 'GET #show' do
      it_behaves_like 'shared behavior for show'
    end
    describe 'GET #edit, PATCH #update, DELETE #destroy' do
      it 'redirects member to project show page and flashes error ' do
        pages = ['get :edit', 'patch :update', 'delete :destroy']
        pages.each do |page|

          page << ', id: project.id'

          eval(page)

          expect(flash[:alert]).to eq 'You do not have access'
          expect(response).to redirect_to project_path(project)
        end
      end
    end
  end

  RSpec.shared_examples 'shared edit, update, and destroy' do
    describe 'GET #edit' do
      it 'allows user to edit a project' do

        get :edit, id: project.id

        expect(assigns(:project)).to eq project
      end
    end
    describe 'PATCH #update' do
      it 'updates a project when user inputs valid params' do

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

        expect {
          delete :destroy, id: project.id
        }.to change { Project.all.count }.by(-1)

        expect(flash[:notice]).to eq 'Project was successfully deleted'
        expect(response).to redirect_to projects_path
      end
    end
  end

  describe 'if user is project owner' do
    before :each do
      membership.update_attributes(role_id: 2)
      session[:user_id] = user.id
    end

    describe 'GET #index' do
      it_behaves_like 'shared behavior for index'
    end
    describe 'GET #new and POST #create' do
      it_behaves_like 'shared behavior for new and create'
    end
    describe 'GET #show' do
      it_behaves_like 'shared behavior for show'
    end
    describe 'GET #edit, PATCH #update, and DELETE #destroy' do
      it_behaves_like 'shared edit, update, and destroy'
    end
  end

  describe 'if user is admin' do
    before :each do
      user.update_attributes(admin: true)
      session[:user_id] = user.id
    end

    describe 'GET #index' do
      it 'should have a list of all projects' do
        project2 = create_project(name: 'Find Jason Statham')
        project3 = create_project(name: 'Defeat Ultron')

        get :index

        expect(assigns(:admin_projects)).to eq [project, project2, project3]
      end
    end
    describe 'GET #new and POST #create' do
      it_behaves_like 'shared behavior for new and create'
    end
    describe 'GET #show' do
      it_behaves_like 'shared behavior for show'
    end
    describe 'GET #edit, PATCH #update, and DELETE #destroy' do
      it_behaves_like 'shared edit, update, and destroy'
    end
  end

end
