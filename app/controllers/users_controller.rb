class UsersController < ApiController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      render json: {
        token: @user.token,
        user_id: @user.id,
        name: @user.name
      }
    else
      render json: @user.errors, status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
