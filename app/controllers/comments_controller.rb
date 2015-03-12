class CommentsController < ApplicationController

  before_action do
    @project = Project.find(params[:project_id])
    @task = Task.find(params[:task_id])
    @user = User.find(current_user)
  end

  def create
    @comment = @task.comments.new(comment_params)
    @comment.update_attributes(user_id: @user.id)
    if @comment.save
      redirect_to project_task_path(@project, @task)
    else
      redirect_to project_task_path(@project, @task)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
