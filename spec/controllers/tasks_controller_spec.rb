require 'rails_helper'

describe TasksController do
  describe 'GET #index' do
    it 'should have a list of tasks if current user is a member of project' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      project2 = create_project(name: 'Form the Avengers')
      membership = create_membership(user, project)
      task = create_task(project)
      task2 = create_task(project, description: 'Save the world')
      task3 = create_task(project2)

      get :index, project_id: project.id

      expect(assigns(:tasks)).to eq [task, task2]
    end

    it 'should redirect user if not a member of project' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      task = create_task(project)

      get :index, project_id: project.id

      expect(response).to redirect_to projects_path
      expect(flash[:alert]).to eq 'You do not have access to that project'
    end

    it 'should redirect to sign in path if user not logged in' do
      project = create_project

      get :index, project_id: project.id

      expect(response).to redirect_to sign_in_path
      expect(flash[:alert]).to eq 'You must sign in'

    end

  end

  describe 'GET #new' do
    it 'should allow member or owner to create new task' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)

      get :new, project_id: project.id

      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe 'POST #create' do
    describe 'on success' do
      it 'create a new project when a member gives it valid params' do
        user = create_user
        session[:user_id] = user.id
        project = create_project
        membership = create_membership(user, project)

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
        user = create_user
        session[:user_id] = user.id
        project = create_project
        membership = create_membership(user, project)

        expect {
          post :create, project_id: project.id, task: { description: nil }
        }.to_not change { Task.all.count }

        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    it 'assigns task to the corresponding task' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)
      task = create_task(project)

      get :show, project_id: project.id, id: task.id

      expect(assigns(:task)).to eq task
    end
  end

  describe 'GET #edit' do
    it 'allows member to edit a task' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)
      task = create_task(project)

      get :edit, project_id: project.id, id: task.id

      expect(assigns(:task)).to eq task
    end
  end

  describe 'PATCH #update' do
    describe 'on success' do
      it 'updates a task when member inputs valid params' do
        user = create_user
        session[:user_id] = user.id
        project = create_project
        membership = create_membership(user, project)
        task = create_task(project)

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
        user = create_user
        session[:user_id] = user.id
        project = create_project
        membership = create_membership(user, project)
        task = create_task(project)

        expect {
          patch :update, project_id: project.id, id: task.id,
          task: { description: nil }
        }.to_not change { task.reload.description }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'allows project member to delete a task' do
      user = create_user
      session[:user_id] = user.id
      project = create_project
      membership = create_membership(user, project)
      task = create_task(project)

      expect {
        delete :destroy, project_id: project.id, id: task.id
      }.to change { Task.all.count }.by(-1)

      expect(flash[:notice]).to eq 'Task was successfully deleted.'
      expect(response).to redirect_to project_tasks_path(project)
    end
  end
end
