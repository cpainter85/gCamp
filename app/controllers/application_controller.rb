class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  helper_method :current_user

  before_action :ensure_current_user

  private

  def current_user
    if session[:user_id].present?
      User.find(session[:user_id])
    end
  end

  def ensure_current_user
    unless current_user
      flash[:alert] = 'You must sign in'
      redirect_to sign_in_path
    end
  end
end
