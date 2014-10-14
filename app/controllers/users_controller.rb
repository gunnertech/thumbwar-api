class UsersController < InheritedResources::Base
  belongs_to :user, optional: true
  
  def register
    user = User.new(params[:user])
    if user.save
      render status: 201, json: {user: user.to_json(only: [:id, :mobile, :username, :first_name, :last_name])}
    else
      render status: 422, json: {errors: user.errors}
    end
  end
  
  def login
    if user = User.find_by_mobile(params[:mobile])
      if user.valid_password?(params[:password])
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
    @current_user.update_column(:token, nil)
    render status: 200, json: {}
  end
  
  def follow
    User.find(params[:user_id]).followers << @current_user
    render status: 200, json: {}
  end
  
  def unfollow
    Following.find_by_followee_id_and_follower_id(params[:user_id], @current_user.id).destroy
    render status: 200, json: {}
  end
  
  private
  
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