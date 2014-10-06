class SessionController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token

  def create
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    render json: {token: current_user.token}, status: 200
  end
  
  def show
    render status: 200, json: {user: current_user}
  end

  def destroy
    token = current_user.token
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    current_user.update_column(:token, nil)
    render status: 200, json: {token: token}
  end

  def failure
    render status: 401, json: {error: "Login failed."}
  end
end