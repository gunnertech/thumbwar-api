class ThumbwarsController < InheritedResources::Base
  # belongs_to :user, optional: true
  
  before_filter :set_challenger_id, only: :create
  
  def watch
    @thumbwar = Thumbwar.find(params[:thumbwar_id])
    @watching = Watching.new
    @watching.side = params[:side]
    @watching.user = @current_user
    @watching.thumbwar = @thumbwar
    
    @watching.save!
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
    
    if params[:user_id].blank? || params[:user_id] == "me"
      user = current_user
    else
      user = User.find_by_username_or_id(params[:user_id])
    end
    
    if params[:view] == 'timeline'
      my_thumbwar_ids = user.thumbwars.pluck('id')
      followee_ids = user.followees.pluck('id')
      followee_thumbwar_ids = Thumbwar.where{ (public == true) & (challenger_id >> my{followee_ids}) }.pluck('id')

      # This is temporary until we decide to make friendship mutual
      follower_ids = user.followers.pluck('id')
      follower_thumbwar_ids = Thumbwar.where{ (public == true) & (challenger_id >> my{follower_ids}) }.pluck('id')

      challenge_thumbwar_ids = user.challenges.pluck('thumbwar_id')
    
      thumbwar_ids = my_thumbwar_ids + followee_thumbwar_ids + challenge_thumbwar_ids + follower_thumbwar_ids

      @thumbwars = @thumbwars.where{ id >> my{thumbwar_ids.uniq} }
    elsif params[:view] == 'mine'
      my_thumbwar_ids = user.thumbwars.pluck('id')
      @thumbwars = @thumbwars.where{ id >> my{my_thumbwar_ids} }
    elsif params[:view] == 'won'
      @thumbwars = @thumbwars.joins{ challenges }.where{ ((status == 'win') & (challenger_id == my{user.id}) ) |  ((status == 'loss') & (challenges.user_id == my{user.id}) )}
    elsif params[:view] == 'lost'
      @thumbwars = @thumbwars.joins{ challenges }.where{ ((status == 'loss') & (challenger_id == my{user.id}) ) |  ((status == 'win') & (challenges.user_id == my{user.id}) )}
    elsif params[:view] == 'push'
      @thumbwars = @thumbwars.joins{ challenges }.where{ ((status == 'push') & (challenger_id == my{user.id}) ) |  ((status == 'push') & (challenges.user_id == my{user.id}) )}
    elsif params[:view] == 'in_progress'
      @thumbwars = @thumbwars.joins{ challenges }.where{ ( (status == 'in_progress') & (challenges.status == 'accepted') ) & ( (challenges.user_id == my{user.id}) | (challenger_id == my{user.id}) ) }
    else
      @thumbwars = @thumbwars.where{ public == true }
    end

    if params[:with_me].present? && params[:with_me] == "true"
      @thumbwars = @thumbwars.where{ (challenges.user_id == my{current_user.id}) | (challenger_id == my{current_user.id}) }
    end

    @total_count = @thumbwars.count
    
    if params[:q].present?
      if params[:q].start_with?('$')
        @thumbwars = @thumbwars.where{ wager == my{params[:q].gsub(/^\$/,"")} }
      elsif params[:q].start_with?('#')
        @thumbwars = @thumbwars.tagged_with(params[:q].gsub(/^#/,""))
      end
    end
    
    if params[:last].present? && params[:last].to_i > 0
      @thumbwars = @thumbwars.where{ id < my{params[:last].to_i}}
    end
    
    if params[:newest].present? && params[:newest].to_i > 0
      @thumbwars = @thumbwars.where{ id > my{params[:newest].to_i}}
    end
    
    if params[:status].present?
      @thumbwars = @thumbwars.where{ status == my{params[:status]}}
    end
    
    @count = @thumbwars.count
    
    @thumbwars = @thumbwars.limit(10)
    
    @thumbwars
  end
end
