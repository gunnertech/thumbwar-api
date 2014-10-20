class ApplicationController < ActionController::Base
  respond_to :json
  
  before_filter :authenticate_from_token!
 
  protected
  
  def current_user
    @current_user ||= User.where{ (mobile == my{params[:mobile]}) & (token == my{params[:token]}) } if params[:token].present? && params[:mobile].present?
  end
  
  def authenticate_from_token!
    if params[:mobile]
      if (user = User.find_by_mobile(params[:mobile]))
        if params[:token]
          if Devise.secure_compare(user.token, params[:token])
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
      render status: 400, json: {error: "no [:mobile] param"}
    end
  end
end