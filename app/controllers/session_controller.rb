class SessionController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token

  def create
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    render json: {authentication_token: current_user.authentication_token}, status: 200
  end

  def destroy
    token = current_user.authentication_token
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    current_user.update_column(:authentication_token, nil)
    render status: 200, json: {authentication_token: token}
  end

  def failure
    render status: 401, json: {}
  end
end