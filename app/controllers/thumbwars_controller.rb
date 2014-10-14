class ThumbwarsController < InheritedResources::Base
  belongs_to :user, optional: true
  
  before_filter :set_challenger_id, only: :create
  
  def watch
    Thumbwar.find(params[:thumbwar_id]).watchers << @current_user
    render status: 200, json: {}
  end
  
  def unwatch
    Thumbwar.find_by_thumbwar_id_and_user_id(params[:thumbwar_id], @current_user.id).destroy rescue nil
    render status: 200, json: {}
  end
  
  def watchers
    render status: 200, json: {users: Thumbwar.find(params[:thumbwar_id]).watchers}
  end
  
  def comment
    params[:comment][:user_id] = @current_user.id
    resource.comments.create!(params[:comment])
  end
  
  private
  
  def set_challenger_id
    params[:thumbwar][:challenger_id] = @current_user.id
  end
  
  def collection
    return @thumbwars if @thumbwars
    
    @thumbwars = if parent.nil?
      Thumbwar.where{ public == true }.order{ id.desc }
    else
      Thumbwar.joins{ watchings.outer }.where{ (challengee_id == my{parent.id}) | (challenger_id == my{parent.id}) | (watchings.user_id == my{parent.id}) }.order{ id.desc }
    end
    
    @thumbwars
  end
end