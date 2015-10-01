# pem = ENV['APNS_PEM'].length < 9 ? "#{Rails.root}/#{ENV['APNS_PEM']}" : StringIO.new(ENV['APNS_PEM'])
#
#
# feedback = Grocer.feedback(
#   certificate: pem,      # required
#   passphrase:  ENV['APNS_PASSPHRASE'],                       # optional
#   gateway:     "feedback.push.apple.com", # optional; See note below.
#   port:        2196,                      # optional
#   retries:     3                          # optional
# )
#
# feedback.each do |attempt|
#   puts "Device #{attempt.device_token} failed at #{attempt.timestamp}"
#
#   Device.where{ token == my{attempt.device_token} }.destroy_all
# end