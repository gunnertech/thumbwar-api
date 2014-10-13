class UsersController < InheritedResources::Base
  def register
    user = User.new(params[:user])
    if user.save
      render status: 201, json: {user: user}
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
    User.find(params[:id]).followers << @current_user
    render status: 200, json: {}
  end
  
  def followers
    render status: 200, json: {users: User.find(params[:user_id]).followers}
  end
end