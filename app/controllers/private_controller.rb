class PrivateController < ApplicationController
  before_action :ensure_current_user

  private

  def ensure_current_user
    unless current_user
      flash[:alert] = 'You must sign in'
      redirect_to sign_in_path
    end
  end
end
