class ApplicationController < ActionController::Base
  respond_to :json
  
  before_filter :authenticate_from_token!
 
  protected
  
  def current_user
    @current_user ||= User.where{ (facebook_id == my{request.headers['thumbwar-facebook-id']}) & (token == my{request.headers['thumbwar-auth-token']}) }.first if request.headers['thumbwar-auth-token'].present? && request.headers['thumbwar-facebook-id'].present?
  end
  
  def authenticate_from_token!
    if request.headers['thumbwar-facebook-id'].present?
      if (user = User.find_by_facebook_id(request.headers['thumbwar-facebook-id']))
        if request.headers['thumbwar-auth-token'].present?
          if Devise.secure_compare(user.token, request.headers['thumbwar-auth-token'])
            @current_user = user
          else
            render status: 401, json: {error: "invalid token"}
          end
        else
          render status: 400, json: {error: "no [:token] param"}
        end
      else
        render status: 404, json: {error: "user not found"}
      end
    else
      render status: 400, json: {error: "no [:facebook_id] param"}
    end
  end
end