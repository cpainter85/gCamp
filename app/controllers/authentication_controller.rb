class AuthenticationController < ApplicationController

  def destroy
    session.clear
    redirect_to root_path, notice: 'You have successfully signed out'
  end

  def new

  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = 'You have successfully signed in'
      redirect_to session[:redirect_back] || projects_path
    else
      @authentication_error = 'Email / Password combination is invalid'
      render :new
    end
  end
end
