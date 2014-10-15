json.(user, :id, :mobile, :username, :first_name, :last_name, :display_name, :public, :publish_to_facebook, :publish_to_twitter, :sms_notifications, :verified)

json.avatar do |avatar|
  avatar.square_url user.avatar.square.url
  avatar.medium_url user.avatar.medium.url
  avatar.background_url user.avatar.background.url
  avatar.lage_url user.avatar.large.url
  avatar.url user.avatar.url
end