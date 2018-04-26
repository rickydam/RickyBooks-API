class SessionsController < ApiController
  skip_before_action :require_login, only: [:create], raise: false

  def create
    if (user = User.valid_login?(params[:email].downcase, params[:password]))
      regenerate_token(user)
      send_token(user)
    else
      render_unauthorized("Invalid email/password combination")
    end
  end

  def destroy
    logout
    head :ok
  end

  private

  def regenerate_token(user)
    user.regenerate_token
  end

  def send_token(user)
    render json: { token: user.token }
  end

  def logout
    current_user.invalidate_token
  end
end
