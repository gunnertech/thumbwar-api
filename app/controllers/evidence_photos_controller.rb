class EvidencePhotosController < InheritedResources::Base
  # belongs_to :user, optional: true
  
  before_filter :set_challenger_id, only: :create
  
  protected
  
  def set_challenger_id
    params[:evidence_photo][:user_id] = @current_user.id
  end
end