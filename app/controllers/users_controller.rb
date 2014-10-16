class UsersController < InheritedResources::Base
  belongs_to :user, optional: true
  skip_before_filter :authenticate_from_token!, only: :index
  
  def register
    password = params.delete(:password)
    
    if password.present? && (id = params.delete(:id)) && (@user = User.find_by_mobile(params[:user][:mobile]))

      if @user.id == id && !@user.verified?
        render status: 422, json: {errors: @user.errors} unless @user.update_attributes(params[:user]) 
      else
        render status: 422, json: {}
      end
    else
      @user = User.new(params[:user])
      @user.password = password if password.present?
      render status: 422, json: {errors: @user.errors} unless @user.save
    end
  end
  
  def login
    mobile_user = User.find_by_mobile(params[:login])
    username_user = User.find_by_username(params[:login])
    if mobile_user || username_user
      @user = mobile_user if mobile_user && mobile_user.valid_password?(params[:password])
      @user ||= username_user if username_user && username_user.valid_password?(params[:password])
      if @user
        @user.save if @user.token.nil?
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
  
  def verify
    if params[:code] == @current_user.verification_code
      @current_user.update_attribute(:verified, true)
      @user = @current_user
    else
      render status: 401, json: {error: "invalid code"}
    end
  end

  def resend_verification
    @current_user.send_confirmation_code(params[:verification_url])
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

  def current_user
    if params[:mobile]
      if (user = User.find_by_mobile(params[:mobile]))
        if params[:token]
          if Devise.secure_compare(user.token, params[:token])
            @current_user = user
          end
        end
      end
    end
    @current_user
  end
  
  def collection
    return @users if @users
    
    @users = if params[:view]
      case params[:view]
      when "followers"
        current_user.followers
      when "following"
        current_user.followees
      else
        User.limit(10)
      end
    elsif params[:search]
      if User.where{ username == my{params[:search]} }.count > 0
        User.where{ username == my{params[:search]} }
      else
        User.where{ mobile == my{params[:search]} }
      end
    else
      User.limit(10)
    end
    
    @users
  end
end