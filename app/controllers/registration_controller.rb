class RegistrationController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token

  def create
    user = User.new(params[:user])
    if user.save
      sign_in user
      render status: 201, json: {user: user}
    else
      render status: 422, json: user.errors
    end
  end
end