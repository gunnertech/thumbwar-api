class ApplicationController < ActionController::Base
  respond_to :json
  
  before_filter :authenticate_from_token!
 
  protected
  
  def current_user
    facebook_id = request.headers['thumbwar-facebook-id']
    token = request.headers['thumbwar-auth-token']
    puts ""
    puts "~~~~~~1 FACEBOOK ID: #{facebook_id}"
    puts ""
    @current_user ||= User.where{ (facebook_id == my{facebook_id}) & (token == my{token}) }.first if token && facebook_id
    
    puts ""
    puts "~~~~~~2 FACEBOOK ID: #{facebook_id}"
    puts ""
    
    @current_user
  end
  
  def authenticate_from_token!
    facebook_id = request.headers['thumbwar-facebook-id']
    token = request.headers['thumbwar-auth-token']
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
