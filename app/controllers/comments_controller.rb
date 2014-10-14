class CommentsController < InheritedResources::Base
  belongs_to :thumbwar, optional: true
  before_filter :set_user_id, only: :create

  private

  def set_user_id
  	params[:comment][:user_id] = @current_user.id
  end
end
