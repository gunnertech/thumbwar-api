class DevicesController < InheritedResources::Base
  before_filter :set_challenger_id, only: :create
  
  def set_user_id
    params[:device][:user_id] = current_user.id
  end
end
