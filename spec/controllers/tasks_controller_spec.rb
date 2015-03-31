require 'rails_helper'

describe TasksController do
  let(:user) { create_user }
  let(:project) { create_project }
  let!(:membership) { create_membership(user, project) }
  let!(:task) { create_task(project) }

  describe 'if user is not signed in' do
    all_pages = ['get :index',
      'get :new',
      'post :create',
      'get :show, id: task.id',
      'get :edit, id: task.id',
      'patch :update, id: task.id',
      'delete :destroy, id: task.id']
    all_pages.each do |page|
      it 'redirects to sign in page with an error message' do
        page << ', project_id: project.id'
        eval(page)
        expect(response).to redirect_to sign_in_path
        expect(flash[:alert]).to eq('You must sign in')
      end
    end
  end

  describe 'if user is not a project member' do

    all_pages = ['get :index',
      'get :new',
      'post :create',
      'get :show, id: task.id',
      'get :edit, id: task.id',
      'patch :update, id: task.id',
      'delete :destroy, id: task.id']
    all_pages.each do |page|
      it 'redirects to projects page with an error message' do
        session[:user_id] = user.id
        membership.destroy

        page << ', project_id: project.id'
        eval(page)
        expect(response).to redirect_to projects_path
        expect(flash[:alert]).to eq('You do not have access to that project')
      end
    end
  end

  RSpec.shared_examples 'shared behavior' do
    describe 'GET #index' do
      it 'should have a list of tasks' do
        project2 = create_project(name: 'Form the Avengers')
        task2 = create_task(project, description: 'Save the world')
        task3 = create_task(project2)

        get :index, project_id: project.id

        expect(assigns(:tasks)).to eq [task, task2]
      end
    end
    describe 'GET #new' do
      it 'should create a new task' do

        get :new, project_id: project.id

        expect(assigns(:task)).to be_a_new(Task)
      end
    end
    describe 'POST #create' do
      describe 'on success' do
        it 'create a new project when given valid params' do

          expect {
            post :create, project_id: project.id,
            task: { description: 'Survive the Walking Dead' }
          }.to change { Task.all.count }.by(1)

          task = Task.last
          expect(task.description).to eq 'Survive the Walking Dead'
          expect(flash[:notice]).to eq 'Task was successfully created.'
          expect(response).to redirect_to project_task_path(project, task)
        end
      end

      describe 'on failure' do
        it 'it should not create a new task when invalid params are passed' do

          expect {
            post :create, project_id: project.id, task: { description: nil }
          }.to_not change { Task.all.count }

          expect(response).to render_template :new
        end
      end
    end
    describe 'GET #show' do
      it 'assigns task to the corresponding task' do

        get :show, project_id: project.id, id: task.id

        expect(assigns(:task)).to eq task
      end
    end
    describe 'GET #edit' do
      it 'able to edit a task' do

        get :edit, project_id: project.id, id: task.id

        expect(assigns(:task)).to eq task
      end
    end

    describe 'PATCH #update' do
      describe 'on success' do
        it 'updates a task when given valid params' do

          expect {
            patch :update, project_id: project.id, id: task.id,
            task: { description: 'Watch The Walking Dead'}
          }.to change { task.reload.description }.from('Race Cars Fast and Furiously').to('Watch The Walking Dead')

          expect(flash[:notice]).to eq 'Task was successfully updated.'
          expect(response).to redirect_to project_task_path(project, task)
        end
      end
      describe 'on failure' do
        it 'does not update task when invalid params are passed' do

          expect {
            patch :update, project_id: project.id, id: task.id,
            task: { description: nil }
          }.to_not change { task.reload.description }

          expect(response).to render_template(:edit)
        end
      end
    end
    describe 'DELETE #destroy' do
      it 'able to delete a task' do

        expect {
          delete :destroy, project_id: project.id, id: task.id
        }.to change { Task.all.count }.by(-1)

        expect(flash[:notice]).to eq 'Task was successfully deleted.'
        expect(response).to redirect_to project_tasks_path(project)
      end
    end
  end

  describe 'project member' do
    before :each do
      session[:user_id] = user.id
    end

    describe 'should allow member to do all task actions' do
      it_behaves_like 'shared behavior'
    end
  end

  describe 'project owner' do
    before :each do
      membership.update_attributes(role_id: 2)
      session[:user_id] = user.id
    end

    describe 'should allow admin to do all task actions' do
      it_behaves_like 'shared behavior'
    end
  end

  describe 'admin' do
    before :each do
      user.update_attributes(admin: true)
      session[:user_id] = user.id
    end

    describe 'should allow admin to do all task actions' do
      it_behaves_like 'shared behavior'
    end
  end
end
