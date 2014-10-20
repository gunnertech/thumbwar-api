class ThumbwarsController < InheritedResources::Base
  belongs_to :user, optional: true
  
  before_filter :set_challenger_id, only: :create
  
  def show
    @thumbwar = Thumbwar.find(params[:id])
    if @thumbwar.challenger == current_user || @thumbwar.challengee == current_user
      show!
    else
      render status: 403, json: {error: "No Authorized"}
    end
  end
  
  def watch
    @thumbwar = Thumbwar.find(params[:thumbwar_id])
    @thumbwar.watchers << @current_user
  end
  
  def unwatch
    @thumbwar = Thumbwar.find(params[:thumbwar_id])
    Watching.find_by_thumbwar_id_and_user_id(params[:thumbwar_id], @current_user.id).destroy rescue nil
  end
  
  def watchers
    render status: 200, json: {users: Thumbwar.find(params[:thumbwar_id]).watchers}
  end
  
  def push
    resource.update_attribute(:winner_id, 0)
    render status: 200, json: {}
  end
  
  protected
  
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