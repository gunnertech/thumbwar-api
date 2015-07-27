if !user.nil?
    json.(user, 
        :id, :mobile, :username, :first_name, :last_name, :display_name, :public, 
        :publish_to_facebook, :publish_to_twitter, :sms_notifications, :email_notifications, 
        :verified, :facebook_id, :email, :name, :sign_in_count, :wins, :losses,
        :pushes, :in_progress_count)

    json.avatar do |avatar|
      avatar.square_url user.avatar.square.url
      # avatar.medium_url user.avatar.medium.url
      # avatar.background_url user.avatar.background.url
      # avatar.lage_url user.avatar.large.url
      # avatar.url user.avatar.url
    end

    # json.devices do
    #  json.array! user.devices, partial: "devices/device", as: :device
    # end
end
