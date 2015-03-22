class TasksController < PrivateController

  before_action do
    @project = Project.find(params[:project_id])
  end

  before_action :ensure_project_member

  def index
    @tasks = @project.tasks
  end

  def new
    @task = @project.tasks.new
  end

  def create
    @task = @project.tasks.new(task_params)
    if @task.save
      redirect_to project_task_path(@project, @task), notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  def show
    @task = @project.tasks.find(params[:id])
  end

  def edit
    @task = @project.tasks.find(params[:id])
  end

  def update
    @task = @project.tasks.find(params[:id])
    if @task.update(task_params)
      redirect_to project_task_path(@project, @task), notice: "Task was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    task = @project.tasks.find(params[:id])
    task.destroy
    redirect_to project_tasks_path(@project), notice: "Task was successfully deleted."

  end

  private

def task_params
  params.require(:task).permit(:description, :complete, :due_date)
end

end
