class ChallengesController < InheritedResources::Base
  prepend_before_filter :set_user_id

  protected
  
  def set_user_id
    params[:challenge][:user_id] = current_user.id
  end
end
