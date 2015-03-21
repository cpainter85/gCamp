class AboutController < ApplicationController

  def index
    @project = Project.all.count
    @task = Task.all.count
    @membership = Membership.all.count
    @user = User.all.count
    @comment = Comment.all.count
  end
end
