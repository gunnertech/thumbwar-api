class ApplicationController < ActionController::Base
  respond_to :json
  
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
 
  private
  
  def authenticate_user_from_token!
    if user_token = params[:user_token].blank? && request.headers["X-User-Token"]
      params[:user_token] = user_token
    end
    if user_email = params[:user_email].blank? && request.headers["X-User-Email"]
      params[:user_email] = user_email
    end
    
    user_email = params[:user_email].presence
    user = user_email && User.find_by_email(user_email)
 
    if user && Devise.secure_compare(user.token, params[:user_token])
      sign_in user, store: false
    end
  end
end