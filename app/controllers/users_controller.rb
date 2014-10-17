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

  def twitter_oauth    
    consumer = OAuth::Consumer.new(ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET'],
    { :site => "https://api.twitter.com",
      :request_token_path => '/oauth/request_token',
      :access_token_path => '/oauth/access_token',
      :authorize_path => '/oauth/authorize',
      :scheme => :header
    })
    
    if params[:oauth_verifier].present? && params[:oauth_token].present?
      request_token = OAuth::RequestToken.new(consumer, session[:token],session[:secret])
      token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])

      @user = current_user
      @user.twitter_token = token.token
      @user.twitter_secret = token.secret
      
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = @user.twitter_token
        config.access_token_secret = @user.twitter_secret
      end
      
      @user.twitter_id = client.user[:id]
      @user.twitter_username = client.user[:screen_name]
      @user.publish_to_twitter = true
      
      @user.save!

      session.delete(:token)
      session.delete(:secret)

      # return_to = session.delete(:return_to)


      
      redirect_to session[:return_to]
    else
      request_token = consumer.get_request_token(:oauth_callback => "#{ENV['HOST']}/twitter_oauth?token=#{params[:token]}&mobile=#{params[:mobile]}")
      # raise request_token.token.inspect
      session[:token] = request_token.token.to_s
      session[:secret] = request_token.secret.to_s

      session[:return_to] = params[:return_to]

      redirect_to request_token.authorize_url
    end
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