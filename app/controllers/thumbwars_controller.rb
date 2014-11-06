class ThumbwarsController < InheritedResources::Base
  # belongs_to :user, optional: true
  
  before_filter :set_challenger_id, only: :create
  
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
    
    @thumbwars = end_of_association_chain.reorder{ id.desc }
    
    if params[:user_id]
      user = User.find_by_user_name_or_id(params[:user_id])
    else
      user = current_user
    end
    
    if params[:view] == 'timeline'
      my_thumbwar_ids = user.thumbwars.pluck('id')
      followee_ids = user.followees.pluck('id')
      followee_thumbwar_ids = Thumbwar.where{ (public == true) & (challenger_id >> my{followee_ids}) }.pluck('id')
      challenge_thumbwar_ids = user.challenges.pluck('thumbwar_id')
    
      thumbwar_ids = my_thumbwar_ids + followee_thumbwar_ids + challenge_thumbwar_ids
    

      @thumbwars = @thumbwars.where{ id >> my{thumbwar_ids.uniq} }
    elsif params[:view] == 'mine'
      my_thumbwar_ids = user.thumbwars.pluck('id')
      @thumbwars = @thumbwars.where{ id >> my{my_thumbwar_ids} }
    else
      @thumbwars = @thumbwars.where{ public == true }
    end
    
    if params[:q].present?
      if params[:q].start_with?('$')
        @thumbwars = @thumbwars.where{ wager == my{params[:q].gsub(/^\$/,"")} }
      elsif params[:q].start_with?('#')
        @thumbwars = @thumbwars.tagged_with(params[:q].gsub(/^#/,""))
      end
    end
    
    @thumbwars
  end
end