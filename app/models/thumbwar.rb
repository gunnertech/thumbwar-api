class Thumbwar < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader
  acts_as_commentable
  acts_as_taggable
  alias_attribute :comments, :comment_threads
  
  attr_accessible :challenger, :challenger_id, :body, :expires_in, :wager, :status,
    :url, :photo, :remote_photo_url, :publish_to_twitter, :publish_to_facebook
    
  attr_accessor :expires_in, :opponent_id
  
  belongs_to :challenger, class_name: "User", foreign_key: "challenger_id"
  
  has_many :watchings
  has_many :watchers, through: :watchings, source: :user
  has_many :alerts, as: :alertable
  has_many :challenges
  has_many :opponents, through: :challenges, foreign_key: :user_id, source: :user
  
  validates :challenger_id, presence: true
  validates :body, presence: true

  before_validation :set_expires_at, if: Proc.new{ |tw| tw.expires_in.present? }
  before_validation :set_properties_from_body, if: Proc.new { |tw| tw.body.present? }
  
  

  after_create :post_to_twitter, if: Proc.new{ |tw| tw.publish_to_twitter? }
  after_create :post_to_facebook, if: Proc.new{ |tw| tw.publish_to_facebook? }
  after_create :complete_url, if: Proc.new { |tw| tw.url.present? }
  after_create :send_expiring_soon_alert, if: Proc.new { |tw| tw.expires_at.present? && tw.expires_at > 20.minutes.from_now }
  
  after_update :send_outcome_alert, if: Proc.new { |tw| tw.status_changed? }
  after_update :update_challenger_record, if: Proc.new { |tw| tw.status_changed? }
  
  after_save :add_opponents, if: Proc.new { |tw| tw.body.present? } 
  after_save :add_opponent, if: Proc.new { |tw| tw.opponent_id.present? } 
  
  
  class << self
  end
  
  def comments_count
    comments.count
  end
  
  def set_properties_from_body
    set_wager_from_body
    set_tag_list_from_body
  end
  
  def has_default_photo
    !photo.present?
  end
    
  def minutes_remaining
    ((expires_at - Time.now)/60).round if expires_at
  end
  
  protected
  
  def set_wager_from_body
    if matches = body.match(/\$([^ \-]+)/)
      self.wager = matches[1]
    end
  end
  
  def add_opponents
    body.scan(/@[^ \-]+/).each do |match|
      user = User.where{ lower(username) == my{match.gsub(/@/,"").try(:downcase)} }.first
      
      if user && !opponents.include?(user)
        c = challenges.build
        c.user = user
        c.challenger = challenger
        c.save!
      end
    end
  end
  
  def add_opponent
    
    user = User.find_by_id(opponent_id)
    
    if user && !opponents.include?(user)
      c = challenges.build
      c.user = user
      c.challenger = challenger
      c.save!
    end
  end
  
  
  def set_tag_list_from_body
    _tags = []
    body.scan(/#[^ \-]+/).each do |match|
      _tags.push(match.gsub(/#/,""))
    end
    
    self.tag_list = _tags.join(",")
    
  end

  def set_expires_at
    self.expires_at = expires_in.to_i.minutes.from_now
  end

  def expiring_soon?
    return false if expires_at.nil? || expires_at - created_at < 20.minutes
    
    expires_at <= 10.minutes.from_now
  end

  def send_expiring_soon_alert
    challenges.where{ status == 'pending' }.each do |challenge|
      challenge.user.alerts.create!(alertable: self, body: "Your Thumbwar is about to expire!") if expiring_soon?
    end
  end
  handle_asynchronously :send_expiring_soon_alert, run_at: Proc.new { |tw| (tw.expires_in.minutes - 10.minutes).from_now }

  
  def twitter_body
    _body = body
    body.scan(/@[^ ]+/).each do |match|
      user = User.where{ lower(username) == my{match.gsub(/@/,"").try(:downcase)} }.first
      if user
        name = user.twitter_username.present? ? "@#{user.twitter_username}" : ""
        _body = _body.gsub(Regexp.new(match),name)
      end
    end
    
    _body
  end

  def post_to_twitter
    challenger.twitter.update("#{twitter_body} #{url}" ) rescue nil
  end
  handle_asynchronously :post_to_twitter

  def post_to_facebook
    challenger.facebook.put_connections("me", "links", 
      link: url.gsub(/localhost/,"test.com"),
      name: "Thumbwar Challenge!",
      message: body,
      picture: photo.url
    )
  end
  handle_asynchronously :post_to_facebook

  def complete_url
    update_column(:url, url.gsub(/\{id\}/,id.to_s))
  end
  
  def update_challenger_record
    if status_was == 'win'
      challenger.decrement(:wins)
    elsif status_was == 'loss'
      challenger.decrement(:losses)
    elsif status_was == 'push'
      challenger.decrement(:pushes)
    end
    
    if status == 'win'
      challenger.increment(:wins)
    elsif status == 'loss'
      challenger.increment(:losses)
    elsif status == 'push'
      challenger.increment(:pushes)
    end
    
    challenger.save!
  end
    
  def send_outcome_alert
    challenges.where{ status == 'accepted' }.each do |challenge|
      new_outcome = status == 'push' ? 'push' : status == 'win' ? 'loss' : status == 'loss' ? 'win' : nil
      if new_outcome
        challenge.outcome = new_outcome
        challenge.save!
      end
      
    end
    watchers.each { |u| u.alerts.create!(alertable: self, body: "A Thumbwar you're watching just ended!") }
  end
  handle_asynchronously :send_outcome_alert


end
