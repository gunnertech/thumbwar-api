class ApplicationController < ActionController::Base
  respond_to :json
  
  before_filter :authenticate_from_token!
 
  protected
  
  def current_user
    facebook_id = request.headers['thumbwar-facebook-id'] || params[:facebook_id]
    token = request.headers['thumbwar-auth-token'] || params[:token]
    @current_user ||= User.where{ (facebook_id == my{facebook_id}) & (token == my{token}) }.first if token && facebook_id
  end
  
  def authenticate_from_token!
    facebook_id = request.headers['thumbwar-facebook-id'] || params[:facebook_id]
    token = request.headers['thumbwar-auth-token'] || params[:token]
    if facebook_id
      if (user = User.find_by_facebook_id(facebook_id))
        if token
          if Devise.secure_compare(user.token, token)
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