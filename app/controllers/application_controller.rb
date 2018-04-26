class ApplicationController < ActionController::API
  include SessionsHelper
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods
end
