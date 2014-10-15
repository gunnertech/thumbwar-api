class CommentsController < InheritedResources::Base
  belongs_to :thumbwar, optional: true
  before_filter :set_user_id, only: :create

  private

  def collection
  	return @comments if @comments

  	@comments = end_of_association_chain.reorder{ id.desc }
  end

  def set_user_id
  	params[:comment][:user_id] = @current_user.id
  end
end
