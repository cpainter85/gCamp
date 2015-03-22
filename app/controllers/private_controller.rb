class PrivateController < ApplicationController
  before_action :ensure_current_user

  private

  def ensure_current_user
    unless current_user
      flash[:alert] = 'You must sign in'
      redirect_to sign_in_path
    end
  end

  def ensure_project_member
    if current_user.memberships.find_by(project_id: @project.id) == nil
      redirect_to projects_path, notice: 'You do not have access to that project'
    end
  end
end
