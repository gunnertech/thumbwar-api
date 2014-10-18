class UsersController < InheritedResources::Base
  belongs_to :user, optional: true
  skip_before_filter :authenticate_from_token!, only: [:register, :login, :forgot_password, :reset_password]
  
  def register
    if password = params.delete(:password)
      if params[:user][:mobile].present?
        if (@user = User.find_by_mobile(params[:user][:mobile])) && !@user.verified?
          @user.password = password
          @user.verified = true if params[:code].present? && params[:code] == @user.verification_code

          render status: 422, json: {errors: @user.errors} unless @user.update_attributes(params[:user])
        else
          @user = User.new(params[:user])
          @user.password = password
          render status: 422, json: {errors: @user.errors} unless @user.save
        end
      else
        render status: 400, json: {error: "no [:user][:mobile] param"}
      end
    else
      render status: 400, json: {errors: "no [:password] param"}
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
      if @current_user.valid_password?(params[:password])
        @current_user.update_attribute(:verified, true)
        @user = @current_user
      else
        render status: 401, json: {error: "invalid password"}
      end
    else
      render status: 401, json: {error: "invalid code"}
    end
  end

  def resend_verification
    @current_user.send_confirmation_code(params[:verification_url])
    render status: 200, json: {}
  end

  def forgot_password
    if user = User.find_by_mobile(params[:login]) || User.find_by_username(params[:login])
      if params[:url].present?
        user.send_reset_password_token(params[:url])
        render status: 200, json: {}
      else
        render status: 400, json: {error: "no [:url] param"}
      end
    else
      render status: 404, json: {error: "user not found"}
    end
  end

  def reset_password
    if user = User.find_by_mobile_and_reset_password_token(params[:mobile], params[:reset_password_token])
      if params[:password].present?
        user.reset_password!(params[:password], nil)
        render status: 200, json: {}
      else
        render status: 400, json: {error: "no [:password] param"}
      end
    else
      render status: 404, json: {error: "user not found"}
    end
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

      @current_user.twitter_token = token.token
      @current_user.twitter_secret = token.secret
      
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = @current_user.twitter_token
        config.access_token_secret = @current_user.twitter_secret
      end
      
      @current_user.twitter_id = client.user[:id]
      @current_user.twitter_username = client.user[:screen_name]
      @current_user.publish_to_twitter = true
      
      @current_user.save!

      session.delete(:token)
      session.delete(:secret)

      redirect_to session[:return_to]
    else
      request_token = consumer.get_request_token(:oauth_callback => "#{ENV['HOST']}/twitter_oauth?token=#{params[:token]}&mobile=#{params[:mobile]}")

      session[:token] = request_token.token.to_s
      session[:secret] = request_token.secret.to_s

      session[:return_to] = params[:return_to]

      redirect_to request_token.authorize_url
    end
  end

  def facebook_oauth
    oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], facebook_oauth_url(mobile: params[:mobile], token: params[:token]))
    if params[:code].present?
      facebook_session = oauth.get_access_token_info(params[:code])

      @current_user.facebook_token = facebook_session["access_token"]
      @current_user.facebook_expires_at = Time.now + facebook_session["expires"].to_i.seconds
      @current_user.publish_to_facebook = true

      
      if @current_user.facebook_id.nil?
        graph = Koala::Facebook::API.new(facebook_session["access_token"])
        profile = graph.get_object("me")
        @current_user.facebook_id = profile["id"]
      end
      
      @current_user.save!
      
      redirect_to session[:return_to]
    else
      redirect_to oauth.url_for_oauth_code(:permissions => "publish_stream,email,user_likes,publish_actions")
    end
  end
  
  protected
  
  def collection
    return @users if @users
    
    @users = if params[:view]
      case params[:view]
      when "followers"
        @current_user.followers
      when "following"
        @current_user.followees
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