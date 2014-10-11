class UsersController < ApplicationController
  def create
    user = User.new(params[:user])
    if user.save
      render status: 201, json: {user: user}
    else
      render status: 422, json: {errors: user.errors}
    end
  end
  
  def show
    render status: 200, json: {user: @user}
  end
  
  def index
    render status: 200, json: {users: collection}
  end
  
  def login
    if user = User.find_by_mobile(params[:mobile])
      if user.token
        render status: 200, json: {token: user.token}
      else
        if user.valid_password?(params[:password])
          user.save
          render status: 200, json: {token: user.token}
        else
          render status: 401, json: {error: "invalid password"}
        end
      end
    else
      render status: 404, json: {error: "user not found"}
    end
  end

  def logout
    @user.update_column(:token, nil)
    render status: 200, json: {}
  end
  
  def follow
    User.find(params[:user_id]).followers << @user
    render status: 200, json: {}
  end
  
  private
  
  def collection
    if params[:collection].present?
      case params[:collection]
      when "followers"
        @user.followers
      else
        User.where{id == 0}
      end
    else
      User.where{id == 0}
    end
  end
end