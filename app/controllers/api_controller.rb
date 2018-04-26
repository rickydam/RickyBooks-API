class ApiController < ApplicationController
  def require_login
    # Call the authenticate_token method
    # If nil, call the render_unauthorized method
    authenticate_token || render_unauthorized("Access denied")
  end

  def current_user
    # If instance variable current_user isn't nil, leave it alone
    # If it is nil, call authenticate_token
    @current_user ||= authenticate_token
  end

  protected

  def render_unauthorized(message)
    errors = { errors: [{ detail: message }] }
    render json: errors, status: :unauthorized
  end

  private

  def authenticate_token
    authenticate_with_http_token do |token, options|
      # Compare the tokens in a time-constant manner to mitigate timing attacks
      if (user = User.find_by(token: token))
        ActiveSupport::SecurityUtils.secure_compare(token, user.token)
        user
      end
    end
  end
end
