class UsersController < InheritedResources::Base
  belongs_to :user, optional: true
  skip_before_filter :authenticate_from_token!, only: [:login, :logout]
  prepend_before_filter :set_inviter_id, only: :create
  
  def show
    if params[:id] == "me"
      @user = current_user
    else
      @user = User.find_by_username_or_id(params[:id])
    end
    
    show!
  end

  def update
    if params[:mobile] != nil
      users = User.where(mobile: params[:mobile])

      for user in users
        if user && user.facebook_token
          unless user == current_user
            render status: 409, json: {error: "mobile exists"}
            return
          end
        else
        end
      end

      current_user.send_verification_sms(params[:mobile])
    end

    update!
  end
    
  def verify
    if params[:verification_code] == current_user.verification_code
      puts "~~~~~~~~~~"
      puts current_user.inspect
      puts "~~~~~~~~~~"
      current_user.verified = true
      current_user.save
      current_user_id = current_user.id
      current_user_mobile = current_user.mobile

      users = User.where{ (mobile == my{current_user_mobile}) & (id != my{current_user_id}) }

      ###173 and 170
      puts "~~~~~~~~~~"
      puts users.inspect
      puts "~~~~~~~~~~"
      

      users.each do |user|
        uid = user.id
        Challenge.where{ user_id == my{uid} }.update_all(user_id: current_user_id)
        Alert.where{ user_id == my{uid} }.update_all(user_id: current_user_id)
        Alert.where{ (alertable_id == my{uid}) & (alertable_type == "User") }.update_all(alertable_id: current_user_id)
      end

      users.delete_all

      render status: 200, json: {}
    else
      render status: 401, json: { error: "invalid code" }
    end
  end

  def login
    if @user = User.find_by_facebook_token(params[:user][:facebook_token])
      if @user.facebook_id == params[:user][:facebook_id]
        if new_avatar_url = params[:user][:remote_avatar_url]
          begin
            @user.update_attribute(:remote_avatar_url, new_avatar_url)
          rescue
            @user = User.find(@user.id)
            @user.update_attribute(:remote_avatar_url, new_avatar_url)
          end
        end
      else
        render status: 401, json: {error: "invalid token"}
      end
    else
      @user = User.new(params[:user])
      profile_data = @user.facebook.get_object("me")
      
      if user = User.find_by_facebook_id(profile_data["id"])
        @user = user
        @user.facebook_token = params[:user][:facebook_token]
      elsif params[:user][:mobile].present? && (user = User.find_by_mobile(params[:user][:mobile]))
        if user.facebook_id.blank? ## THIS MEANS THEY WERE INVITED BY SOMEONE VIA MOBILE NUMBER
          @user = user
          @user.attributes = params[:user]
        end
      end
    end
    
    if @user.valid?
      @user.sign_in_count = @user.sign_in_count + 1
      @user.save!
    else
      render status: 401, json: {error: "invalid token"}
    end
  end

  def logout
    @current_user.update_attribute(:token, nil) if @current_user
    render status: 200, json: {}
  end
  
  def follow
    @current_user.followees << User.find(params[:user_id])
    render status: 200, json: {}
  end
  
  def unfollow
    @current_user.followees.delete(User.find(params[:user_id]))
    # Following.find_by_followee_id_and_follower_id(params[:user_id], @current_user.id).destroy
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
      request_token = consumer.get_request_token(:oauth_callback => "#{ENV['HOST']}/twitter_oauth?token=#{params[:token]}&facebook_id=#{params[:facebook_id]}")

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
      session[:return_to] = params[:return_to]
      redirect_to oauth.url_for_oauth_code(:permissions => "publish_stream,email,user_likes,publish_actions")
    end
  end
  
  protected
  
  def set_inviter_id
    params[:user][:inviter_id] = current_user.id unless current_user.nil?
  end
  
  def collection
    if params[:user_id] == "me"
      @user = current_user
    else
      @user = User.find_by_username_or_id(params[:user_id]) if params[:user_id].present?
    end
    
    return @users if @users
    
    @users = if params[:view]
      case params[:view]
      when "followers"
        @user.followers
      when "following"
        @user.followees
      else
        User.limit(10)
      end
    elsif params[:search]
      params[:search] = params[:search].squish
      if params[:search].match(/,/)
        searches = params[:search].split(",")
        User.where{ (email >> my{searches}) | (mobile >> my{searches}) }
      elsif params[:search].match(/@/)
        User.where{ email == my{params[:search]} }
      elsif User.where{ username == my{params[:search]} }.count > 0
        User.where{ username == my{params[:search]} }
      elsif User.where{ facebook_id == my{params[:search]} }.count > 0
        User.where{ facebook_id == my{params[:search]} }
      elsif !params[:search].to_s.match(/\d/)
        name_pieces = params[:search].split(" ")
        if name_pieces.count > 1
          l_name = name_pieces.last
          f_name = (name_pieces - [l_name]).join(" ")
        else
          f_name = name_pieces.first
        end
        
        if l_name.present? && f_name.present?
          User.where{ (first_name =~ "#{f_name}%") & (last_name =~ "#{l_name}%") }
        elsif f_name.present?
          User.where{ first_name =~ "#{f_name}%" }
        else
          User.where{ id == 0 }
        end
        
      else
        search = params[:search].gsub(/\D/,"")
        search = "1#{search}" if search.length < 11
        User.where{ mobile == my{search} }
      end
    else
      User.limit(10)
    end

    if params[:limitTo].present?
      @users = @users.limit(params[:limitTo].to_i)
    end
    
    @users
  end
end
