class UsersController < InheritedResources::Base
  belongs_to :user, optional: true
  
  def register
    user = User.new(params[:user])
    if user.save
      render status: 201, json: {user: user.to_json}
    else
      render status: 422, json: {errors: user.errors}
    end
  end
  
  def login
    mobile_user = User.find_by_mobile(params[:login])
    username_user = User.find_by_username(params[:login])
    if mobile_user || username_user
      user = mobile_user if mobile_user && mobile_user.valid_password?(params[:password])
      user ||= username_user if username_user && username_user.valid_password?(params[:password])
      if user
        user.save if user.token.nil?
        render status: 200, json: {user: user.to_json(only: [:mobile, :token])}
      else
        render status: 401, json: {error: "invalid password"}
      end
    else
      render status: 404, json: {error: "user not found"}
    end
  end

  def logout
    @current_user.update_attribute(:token, nil)
    render status: 200, json: {}
  end
  
  def follow
    User.find(params[:user_id]).followers << @current_user
    render status: 200, json: {}
  end
  
  def unfollow
    Following.find_by_followee_id_and_follower_id(params[:user_id], @current_user.id).destroy rescue nil
    render status: 200, json: {}
  end
  
  protected
  
  def collection
    return @users if @users
    
    @users = if params[:view]
      case params[:view]
      when "followers"
        parent.followers
      when "following"
        parent.followees
      else
        User.all
      end
    else
      User.all
    end
    
    @users
  end
end