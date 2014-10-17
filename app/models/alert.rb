class Alert < ActiveRecord::Base
  attr_accessible :alertable, :alertable_type, :alertable_id, :body, :read, :user_id
  
  belongs_to :alertable, polymorphic: true
  belongs_to :user
  
  validates :alertable_type, presence: true
  validates :alertable_id, presence: true
  validates :user_id, presence: true
  
  after_create :send_sms, if: Proc.new { |a| a.user.sms_notifications }
  
  protected
  
  def send_sms
    client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    number = ENV['TWILIO_NUMBERS'].split(",").sample

    url = if alertable_type == "Thumbwar"
      alertable.url
    elsif alertable_type == "Comment"
      alertable.commentable.url
    end

    client.account.sms.messages.create(
      from: "+1#{number}",
      to: "+#{user.mobile}",
      body: "#{body} #{url}".squish
    )
  end
end
