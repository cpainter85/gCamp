class ProjectsController < PrivateController
  before_action :find_project, except: [:index, :new, :create]
  before_action :ensure_project_member_or_admin, only: [:show, :edit, :update, :destroy]
  before_action :ensure_project_owner_or_admin, only: [:edit, :update, :destroy]

  def index
    @projects = current_user.projects
    @admin_projects = Project.all
    tracker_api = TrackerAPI.new

    if current_user.pivotal_tracker_token
      @tracker_projects = tracker_api.projects(current_user.pivotal_tracker_token)
      if @tracker_projects == 403
        flash.now[:alert] = "Pivotal Tracker Token is invalid"
      end
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      @project.memberships.create(user_id: current_user.id, role_id: 2)
      redirect_to project_tasks_path(@project), notice: 'Project was successfully created'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to project_path(@project), notice: 'Project was successfully updated'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted'
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

  def find_project
    @project = Project.find(params[:id])
  end
end
