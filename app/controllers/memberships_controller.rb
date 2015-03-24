class MembershipsController < PrivateController

  before_action do
    @project = Project.find(params[:project_id])
  end
  before_action :find_membership, except: [:index, :create]
  before_action :ensure_project_member
  before_action :ensure_project_owner, except: [:index, :destroy]
  before_action :ensure_project_owner_or_self, only: [:destroy]

  def index
    @membership = @project.memberships.new
  end

  def create
    @membership = @project.memberships.new(membership_params)
    if @membership.save
      flash[:notice] = "#{@membership.user.full_name} was successfully added"
      redirect_to project_memberships_path(@project)
    else
      render :index
    end
  end

  def update
    if @membership.update(membership_params)
      flash[:notice] = "#{@membership.user.full_name} was successfully updated"
      redirect_to project_memberships_path(@project)
    else
      render :index
    end
  end

  def destroy
    @membership.destroy
    flash[:notice] = "#{@membership.user.full_name} was successfully removed"
    if current_user == @membership.user
      redirect_to projects_path
    else
      redirect_to project_memberships_path(@project)
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:project_id, :user_id, :role_id)
  end

  def find_membership
    @membership = @project.memberships.find(params[:id])
  end
end
