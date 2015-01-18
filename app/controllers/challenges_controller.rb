class ChallengesController < InheritedResources::Base
  before_filter :set_challenger_id, only: :create

  protected
  
  def set_user_id
    params[:challenge][:challenger_id] = current_user.id
  end
end
