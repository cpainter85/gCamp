class PrivateController < ApplicationController
  before_action :ensure_current_user

  @projects = Project.all

  private

  def ensure_current_user
    unless current_user
      flash[:alert] = 'You must sign in'
      redirect_to sign_in_path
    end
  end

  def ensure_project_member_or_admin
    # if current_user.memberships.find_by(project_id: @project.id) == nil
    if !current_user.admin_or_project_member(@project)
      flash[:alert] = 'You do not have access to that project'
      redirect_to projects_path
    end
  end

  def ensure_project_owner_or_admin
    if !current_user.project_owner_or_admin(@project)
      flash[:alert] = 'You do not have access'
      redirect_to project_path(@project)
    end
  end

  def ensure_project_owner_or_self
    if !(current_user.project_owner_or_admin(@project) || @membership.user == current_user)
      flash[:alert] = 'You do not have access'
      redirect_to project_path(@project)
    end
  end

  def ensure_user_is_logged_in_user_or_admin
    if current_user != @user && !current_user.admin
      render file: 'public/404.html', status: :not_found, layout: false
    end
  end
end
