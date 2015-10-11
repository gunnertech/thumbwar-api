class Alert < ActiveRecord::Base
  attr_accessible :alertable, :alertable_type, :alertable_id, :body, :read, :user_id, :opened
  
  belongs_to :alertable, polymorphic: true
  belongs_to :user
  
  validates :alertable_type, presence: true
  validates :alertable_id, presence: true
  validates :user_id, presence: true
  
  after_create :send_sms, if: Proc.new { |a| a.user.mobile.present? && a.user.sms_notifications? && !a.user.facebook_id.blank? }
  after_create :send_push
  after_create :send_email, if: Proc.new { |a| a.user.email.present? && a.user.email_notifications? && !a.user.facebook_id.blank? }
  
  def url
    if alertable_type == "Thumbwar"
      alertable.url
    elsif alertable_type == "Comment"
      alertable.commentable.url
    end
  end

  def subject_type
    if alertable_type == "Thumbwar" || alertable_type == "Comment"
      "thumbwar"
    elsif alertable_type == "User"
      "user"
    end
  end

  def subject_id
    if alertable_type == "Thumbwar"
      alertable_id
    elsif alertable_type == "User"
      alertable_id
    elsif alertable_type == "Comment"
      alertable.commentable_id
    end
  end
  
  protected
  
  def send_push
    pem = ENV['APNS_PEM'].length < 9 ? "#{Rails.root}/#{ENV['APNS_PEM']}" : StringIO.new(ENV['APNS_PEM'])
    # raise pem
    pusher = Grocer.pusher(
      certificate: pem,      # required
      passphrase:  ENV['APNS_PASSPHRASE'],                       # optional
      gateway:     ENV['APNS_GATEWAY']#, # optional; See note below.
      # port:        2195,                     # optional
      # retries:     3                         # optional
    )


    feedback = Grocer.feedback(
      certificate: pem,      # required
      passphrase:  ENV['APNS_PASSPHRASE'],                       # optional
      gateway:     "feedback.push.apple.com", # optional; See note below.
      port:        2196,                      # optional
      retries:     3                          # optional
    )

    feedback.each do |attempt|
      puts "Device #{attempt.device_token} failed at #{attempt.timestamp}"
  
      Device.where{ token == my{attempt.device_token} }.destroy_all
    end
    
    if user
    
      user.devices.where{ device_type == 'ios' }.each do |device|
      
        # category:          "a category",         # optional; used for custom notification actions
        # sound:             "siren.aiff",         # optional
        # expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        # identifier:        1234,                 # optional; must be an integer
        # content_available: true                  # optional; any truthy value will set 'content-available' to 1
        notification = Grocer::Notification.new(
          device_token:      device.token,
          alert:             body,
          badge:             (user.alerts.where{ read == false }.count),
          content_available: true,
          custom: {
            message: body,
            url: url,
            subject_type: subject_type,
            subject_id: subject_id
          }
        )

        pusher.push(notification)
      end
    end
  end
  handle_asynchronously :send_push
  
  def send_sms
    client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
    number = ENV['TWILIO_NUMBERS'].split(",").sample

    client.account.sms.messages.create(
      from: "+1#{number}",
      to: "+#{user.mobile}",
      body: "#{body} #{url}".squish
    )
  end
  handle_asynchronously :send_sms
  
  def send_email
    ActionMailer::Base.mail(
      from: "no-reply@thumbwarapp.com", 
      to: user.email, 
      subject: "ThumbWar Alert", 
      body: "#{body} #{url}".squish
    ).deliver rescue nil
  end
  handle_asynchronously :send_email
end
