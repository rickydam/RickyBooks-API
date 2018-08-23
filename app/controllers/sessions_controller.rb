class SessionsController < ApiController
  skip_before_action :require_login, only: [:create], raise: false

  def create
    if (user = User.valid_login?(params[:email].downcase, params[:password]))
      if user.token == nil
        regenerate_token(user)
      end
      send_response(user)
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

  def send_response(user)
    render json: {
      token: user.token,
      user_id: user.id,
      name: user.name
    }
  end

  def logout
    current_user.invalidate_token
    current_user.invalidate_firebase_token
  end
end
