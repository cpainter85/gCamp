class UsersController < PrivateController

  before_action :find_user, except: [:index, :new, :create]
  before_action :ensure_user_is_logged_in_user, only: [:update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.set_user_id_nil_on_comments
    if @user == current_user
      session.clear
      @user.destroy
      redirect_to root_path, notice: 'User was successfully deleted.'
    else
      @user.destroy
      redirect_to users_path, notice: 'User was successfully deleted.'
    end
  end

  private

  def user_params
    if current_user.admin
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :admin)
    else
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
  end

  def find_user
    @user = User.find(params[:id])
  end



end
